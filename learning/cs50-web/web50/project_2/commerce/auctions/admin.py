from django.contrib import admin

# Register your models here.
from .models import Auction_listing, User, Watchlist, Bid, ListingStatus, Comment, Category

admin.site.register(Watchlist)
admin.site.register(Auction_listing)
admin.site.register(User)
admin.site.register(Bid)
admin.site.register(ListingStatus)
admin.site.register(Comment)
admin.site.register(Category)

