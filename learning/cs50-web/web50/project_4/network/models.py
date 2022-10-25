from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    pass


class Profile(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="%(class)s_user")
    follower = models.ManyToManyField(User, related_name="Profile_follower")

    def serialize(self, user):
        return {
            "profile_user_id": self.user.id,
            "username": self.user.username,
            "follower": self.follower.count(),
            "following": self.user.Profile_follower.count(),
            "followed": not user.is_anonymous and self in user.Profile_follower.all(),
            "can_follow": not user.is_anonymous and self.user != user
        }

class Post(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="%(class)s_user")
    timestamp = models.DateTimeField(auto_now_add=True)
    post = models.CharField(max_length=1000)
    reaction = models.ManyToManyField(User, related_name="Liked")

    def serialize(self, user):
        return {
            "id": self.id,
            "post": self.post,
            "timestamp": self.timestamp.strftime("%b %d %Y, %I:%M %p"),
            "user": self.user.username,
            "userid": self.user.id,
            "like_num": self.reaction.count(),
            "liked": self in user.Liked.all()
        }

