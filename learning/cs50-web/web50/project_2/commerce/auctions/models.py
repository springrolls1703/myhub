from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    id = models.AutoField(primary_key=True)
    pass

class Auction_listing(models.Model):
    id = models.AutoField(primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="%(class)s_bidowner")
    title = models.CharField(max_length=64)
    description = models.CharField(max_length=64)
    starting_bid = models.FloatField()
    image_url = models.URLField()
    category = models.CharField(max_length=150)
    
    def __str__(self):
        return f"{self.title} starting at {self.starting_bid}"


class Watchlist(models.Model):
    id = models.AutoField(primary_key=True)
    list_object = models.ForeignKey(Auction_listing, on_delete=models.CASCADE, related_name="watchlist_object")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="watchlist_owner")

    def _str_(self):
        return f"{self.user.username} added {self.list_object.title} to watch list"

class Bid(models.Model):
    id = models.AutoField(primary_key=True)
    list_object = models.ForeignKey(Auction_listing, on_delete=models.CASCADE, related_name="bid_object")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="bid_owner")
    bid = models.FloatField(default=0)
    
    def _str_(self):
        return f"{self.user.username} bidded {self.bid} on {self.list_object.title}"

class ListingStatus(models.Model):
    id = models.AutoField(primary_key=True)
    list_object = models.OneToOneField(Auction_listing, on_delete=models.CASCADE, related_name="status_object")
    status = models.CharField(max_length=64,default="Active")

    def _str_(self):
        return f"{self.list_object} is set to {self.status}"

class Comment(models.Model):
    id = models.AutoField(primary_key=True)
    list_object = models.ForeignKey(Auction_listing, on_delete=models.CASCADE, related_name="comment_object")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="comment_user")
    comment = models.CharField(max_length=300)

    def _str_(self):
        return f"{self.user.username} commented on {self.list_object.title}"

class Category(models.Model):
    id = models.AutoField(primary_key=True)
    category = models.CharField(max_length=150)

    def _str_(self):
        return f"{self.category}"