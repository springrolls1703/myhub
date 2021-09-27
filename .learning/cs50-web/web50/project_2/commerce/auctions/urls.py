from django.urls import path

from . import views

app_name = "auctions"
urlpatterns = [
    path("", views.index, name="index"),
    path("login", views.login_view, name="login"),
    path("logout", views.logout_view, name="logout"),
    path("register", views.register, name="register"),
    path("create-listing", views.create_listing, name="create_listing"),
    path("submit-listing", views.submit_listing, name="submit_listing"),
    path("listing/<int:id>", views.listing, name="listing"),
    path("bidding-submit", views.bidding_submit, name="bidding_submit"),
    path("watchlist-listing", views.watchlist_listing, name="watchlist_listing"),
    path("watchlist-submit", views.watchlist_submit, name="watchlist_submit"),
    path("status-listing", views.status_listing, name="status_listing"),
    path("comment-listing", views.comment_listing, name="comment_listing"),
    path("categories", views.categories, name="categories"),
    path("categories/<int:id>", views.category_listing, name="category_listing")
]
