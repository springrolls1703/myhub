
from django.urls import path

from . import views

# app_name = "network"
urlpatterns = [
    path("", views.index, name="index"),
    path("login", views.login_view, name="login"),
    path("logout", views.logout_view, name="logout"),
    path("register", views.register, name="register"),
    path("post", views.new_post, name="new_post"),

    # API Routes
    path("load", views.load, name="load"),
    path("profile/<int:id>", views.load_profile, name="profile"),
    path("load-post/<int:id>", views.load_profile_post, name="profile-post"),
    path("follow/<int:id>", views.follow, name="follow"),
    path("following",views.following, name="following"),
    path("edit-post/<int:id>", views.edit_post, name="edit"),
    path("like/<int:id>", views.like_post, name="like-post"),
    path("following-post", views.following_post, name="following-post")
    
]
