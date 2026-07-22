from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import select, and_, exists
from app.db.session import get_db
from app.models.models import User, Community, Post, Comment, Like, community_members, Profile
from app.schemas.schemas import CommunityResponse, CommunityCreate, PostResponse, PostCreate, CommentResponse, CommentCreate
from app.api.deps import get_current_user
from typing import List, Optional
import uuid

router = APIRouter()

@router.get("/", response_model=List[CommunityResponse])
def get_communities(category: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Community)
    if category:
        query = query.filter(Community.category == category)
    return query.all()

@router.post("/", response_model=CommunityResponse)
def create_community(data: CommunityCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    existing = db.query(Community).filter(Community.slug == data.slug).first()
    if existing:
        raise HTTPException(status_code=400, detail="Community slug already exists")
    
    community = Community(
        name=data.name,
        slug=data.slug,
        description=data.description,
        category=data.category,
        icon_url=data.icon_url,
        banner_url=data.banner_url,
        city_name=data.city_name,
        is_verified=False
    )
    db.add(community)
    db.flush()

    # Automatically add creator as owner member
    db.execute(community_members.insert().values(
        community_id=community.id,
        user_id=current_user.id,
        role="admin"
    ))
    community.member_count = 1
    db.commit()
    db.refresh(community)
    return community

@router.post("/{community_id}/join")
def join_community(community_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    community = db.query(Community).filter(Community.id == community_id).first()
    if not community:
        raise HTTPException(status_code=404, detail="Community not found")
    
    # Check if already a member
    stmt = select(community_members).where(
        and_(community_members.c.community_id == community_id, community_members.c.user_id == current_user.id)
    )
    existing = db.execute(stmt).first()
    if existing:
        return {"status": "already_joined"}

    db.execute(community_members.insert().values(
        community_id=community_id,
        user_id=current_user.id,
        role="member"
    ))
    community.member_count += 1
    db.commit()
    return {"status": "success", "message": "Joined community successfully"}

@router.post("/{community_id}/leave")
def leave_community(community_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    community = db.query(Community).filter(Community.id == community_id).first()
    if not community:
        raise HTTPException(status_code=404, detail="Community not found")
    
    stmt = community_members.delete().where(
        and_(community_members.c.community_id == community_id, community_members.c.user_id == current_user.id)
    )
    res = db.execute(stmt)
    if res.rowcount > 0:
        community.member_count = max(0, community.member_count - 1)
        db.commit()
    return {"status": "success", "message": "Left community successfully"}

@router.get("/{community_id}/posts", response_model=List[PostResponse])
def get_community_posts(community_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    posts = db.query(Post).filter(Post.community_id == community_id).order_by(Post.is_pinned.desc(), Post.created_at.desc()).all()
    
    responses = []
    for post in posts:
        author_profile = db.query(Profile).filter(Profile.user_id == post.author_id).first()
        is_liked = db.query(exists().where(and_(Like.user_id == current_user.id, Like.post_id == post.id))).scalar()
        
        responses.append(PostResponse(
            id=post.id,
            community_id=post.community_id,
            author_id=post.author_id,
            author_name=author_profile.full_name if author_profile else "Anonymous",
            author_avatar=author_profile.avatar_url if author_profile else None,
            content=post.content,
            media_urls=post.media_urls,
            is_pinned=post.is_pinned,
            is_announcement=post.is_announcement,
            likes_count=post.likes_count,
            comments_count=post.comments_count,
            is_liked_by_me=is_liked,
            created_at=post.created_at
        ))
    return responses

@router.post("/{community_id}/posts", response_model=PostResponse)
def create_post(community_id: uuid.UUID, data: PostCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    community = db.query(Community).filter(Community.id == community_id).first()
    if not community:
        raise HTTPException(status_code=404, detail="Community not found")
        
    post = Post(
        community_id=community_id,
        author_id=current_user.id,
        content=data.content,
        media_urls=data.media_urls,
        is_pinned=data.is_pinned,
        is_announcement=data.is_announcement
    )
    db.add(post)
    db.commit()
    db.refresh(post)

    author_profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    return PostResponse(
        id=post.id,
        community_id=post.community_id,
        author_id=post.author_id,
        author_name=author_profile.full_name if author_profile else "Anonymous",
        author_avatar=author_profile.avatar_url if author_profile else None,
        content=post.content,
        media_urls=post.media_urls,
        is_pinned=post.is_pinned,
        is_announcement=post.is_announcement,
        likes_count=0,
        comments_count=0,
        is_liked_by_me=False,
        created_at=post.created_at
    )

@router.post("/posts/{post_id}/like")
def toggle_like_post(post_id: uuid.UUID, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    
    existing = db.query(Like).filter(and_(Like.user_id == current_user.id, Like.post_id == post_id)).first()
    if existing:
        db.delete(existing)
        post.likes_count = max(0, post.likes_count - 1)
        db.commit()
        return {"status": "unliked", "likes_count": post.likes_count}
    else:
        like = Like(user_id=current_user.id, post_id=post_id)
        db.add(like)
        post.likes_count += 1
        db.commit()
        return {"status": "liked", "likes_count": post.likes_count}

@router.get("/posts/{post_id}/comments", response_model=List[CommentResponse])
def get_comments(post_id: uuid.UUID, db: Session = Depends(get_db)):
    comments = db.query(Comment).filter(Comment.post_id == post_id).order_by(Comment.created_at.asc()).all()
    responses = []
    for c in comments:
        author_profile = db.query(Profile).filter(Profile.user_id == c.author_id).first()
        responses.append(CommentResponse(
            id=c.id,
            post_id=c.post_id,
            author_id=c.author_id,
            author_name=author_profile.full_name if author_profile else "Anonymous",
            author_avatar=author_profile.avatar_url if author_profile else None,
            content=c.content,
            created_at=c.created_at
        ))
    return responses

@router.post("/posts/{post_id}/comments", response_model=CommentResponse)
def add_comment(post_id: uuid.UUID, data: CommentCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
        
    comment = Comment(
        post_id=post_id,
        author_id=current_user.id,
        content=data.content
    )
    db.add(comment)
    post.comments_count += 1
    db.commit()
    db.refresh(comment)

    author_profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    return CommentResponse(
        id=comment.id,
        post_id=comment.post_id,
        author_id=comment.author_id,
        author_name=author_profile.full_name if author_profile else "Anonymous",
        author_avatar=author_profile.avatar_url if author_profile else None,
        content=comment.content,
        created_at=comment.created_at
    )
