from django.contrib.auth import authenticate, login, logout
from django.db import IntegrityError
from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import render
from django.urls import reverse
from django.shortcuts import redirect
from django.shortcuts import get_object_or_404
from django.contrib import messages
from django import forms


from .models import User, Auction_listing, Watchlist, Bid, ListingStatus, Comment, Category


def index(request):
    selected_listing = Auction_listing.objects.all().select_related('user').prefetch_related('bid_object')
    removed_listing = ListingStatus.objects.all()
    selected_listing = selected_listing.exclude(id__in=[o.list_object.id for o in removed_listing])

    selected_listing = [(o, o.bid_object.all().first()) for o in selected_listing]
    return render(request, "auctions/index.html", {
        'selected_listing': selected_listing
    })

def login_view(request):
    if request.method == "POST":

        # Attempt to sign user in
        username = request.POST["username"]
        password = request.POST["password"]
        user = authenticate(request, username=username, password=password)

        # Check if authentication successful
        if user is not None:
            login(request, user)
            return HttpResponseRedirect(reverse("auctions:index"))
        else:
            return render(request, "auctions/login.html", {
                "message": "Invalid username and/or password."
            })
    else:
        return render(request, "auctions/login.html")


def logout_view(request):
    logout(request)
    return HttpResponseRedirect(reverse("auctions:index"))


def register(request):
    if request.method == "POST":
        username = request.POST["username"]
        email = request.POST["email"]

        # Ensure password matches confirmation
        password = request.POST["password"]
        confirmation = request.POST["confirmation"]
        if password != confirmation:
            return render(request, "auctions/register.html", {
                "message": "Passwords must match."
            })

        # Attempt to create new user
        try:
            user = User.objects.create_user(username, email, password)
            user.save()
        except IntegrityError:
            return render(request, "auctions/register.html", {
                "message": "Username already taken."
            })
        login(request, user)
        return HttpResponseRedirect(reverse("auctions:index"))
    else:
        return render(request, "auctions/register.html")

def create_listing(request):
    category_list = [o.category for o in Category.objects.all()]
    return render(request, "auctions/create_listing.html", {
        'category_list': category_list
    })

def submit_listing(request):
    if request.method == "POST":
        if request.user.is_authenticated:
            user = request.user
            title = request.POST["title"]
            description = request.POST["description"]
            starting_bid = request.POST["starting_bid"]
            image_url = request.POST["image_url"]
            category = request.POST["category"]
            submission = Auction_listing(user=user, title=title, description=description, starting_bid=starting_bid, image_url=image_url, category=category)
            submission.save()
            return HttpResponseRedirect(reverse("auctions:index"))
        else:   
            return render(request, "auctions/login.html")
    else:
        return render(request, "auctions/index.html")

def listing(request, id):
    selected_listing = Auction_listing.objects.get(pk=id)
    selected_currentbid = 0
    currentbid_user = None
    comment = None
    try:
        currentbid_item = Bid.objects.get(list_object=selected_listing)
        currentbid_user = currentbid_item.user
        selected_currentbid = currentbid_item.bid
    except Exception as e:
        selected_currentbid = selected_listing.starting_bid
    
    try:
        comment = Comment.objects.filter(list_object=selected_listing).all()
    except Exception as e:
        comment

    status_message = ""
    if selected_listing.user is request.user:
        status_message = "Close Auction"
    else:
        status_message = ""


    if request.user.is_authenticated:
        user = request.user
        message = "Add to Watchlist"
        try:
            watch_list = Watchlist.objects.get(user=user, list_object=selected_listing)
            message = "Remove from Watchlist"
        except Exception as e:
            message = "Add to Watchlist"

        
        if selected_listing.user == request.user:
            status_message = "Close Auction"
            return render(request, "auctions/listing.html", {
                'selected_listing': selected_listing,
                'watch_list_status': message,
                'current_bid': selected_currentbid,
                'status_message': status_message,
                'comment': comment
            })
        elif currentbid_user != None and request.user == currentbid_user and (selected_listing in [o.list_object for o in ListingStatus.objects.all()]):
            auction_message = "Congratulations! You won the auction of this listing."
            return render(request, "auctions/listing.html", {
                'selected_listing': selected_listing,
                'watch_list_status': message,
                'current_bid': selected_currentbid,
                'auction_message': auction_message,
                'comment': comment
            })
        else:
            return render(request, "auctions/listing.html", {
                'selected_listing': selected_listing,
                'watch_list_status': message,
                'current_bid': selected_currentbid,
                'comment': comment
            })
    else:
        return render(request, "auctions/listing.html", {
            'selected_listing': selected_listing,
            'current_bid': selected_currentbid,
            'comment': comment
        })        

def watchlist_listing(request):
    if request.user.is_authenticated:
        selected_watchlist = Watchlist.objects.filter(user = request.user).select_related('list_object')
        watch_list_id = [o.list_object.id for o in selected_watchlist]
        selected_listing = Auction_listing.objects.filter(id__in=watch_list_id).prefetch_related('bid_object')
        removed_listing = ListingStatus.objects.all()
        selected_listing = selected_listing.exclude(id__in=[o.list_object.id for o in removed_listing])
        selected_listing = [(o, o.bid_object.all().first()) for o in selected_listing]
        return render(request, "auctions/watchlist.html", {
            'selected_listing': selected_listing
        })
    else: 
        return render(request, "auctions/watchlist.html")

def categories(request):
    category_list = Category.objects.all()
    return render(request, "auctions/categories.html", {
        'category_list': category_list
    })

def category_listing(request, id):
    category = Category.objects.get(pk=id).category
    selected_listing = Auction_listing.objects.filter(category=category).prefetch_related('bid_object')
    removed_listing = ListingStatus.objects.all()
    selected_listing = selected_listing.exclude(id__in=[o.list_object.id for o in removed_listing])
    selected_listing = [(o, o.bid_object.all().first()) for o in selected_listing]
    return render(request, "auctions/category_listing.html", {
            'selected_listing': selected_listing
    })
    
    

def watchlist_submit(request):
    if request.method == "POST":
        listingid = request.POST["listingid"]
        userid = request.POST["userid"]
        status = request.POST["status"]
        list_object = Auction_listing.objects.get(pk=listingid)
        user = User.objects.get(pk=userid)
        if status == "remove":
            try:
                watchlist_item = Watchlist.objects.get(list_object=list_object, user=user)
                watchlist_item.delete()
                return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
            except Exception as e:
                print(e)
                return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
        elif status == "add":
            watchlist_item = Watchlist(list_object=list_object, user=user)
            watchlist_item.save()
            return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
        else:
            return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
    else:
        HttpResponse("can't added to watch list")

def bidding_submit(request):
    if request.method == "POST" and request.user.is_authenticated:
        listingid = request.POST["listingid"]
        userid = request.POST["userid"]
        bid = float(request.POST["bid"])
        list_object = Auction_listing.objects.get(pk=listingid)
        user = User.objects.get(pk=userid)
        if bid <= list_object.starting_bid:
            messages.warning(request, 'your bid must be at least greater than the starting bid.')
            return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
        else:
            try:
                bid_item = Bid.objects.get(list_object=list_object)
                if bid > bid_item.bid:
                    bid_item.delete()
                    new_bid_item = Bid(list_object=list_object, user=user, bid=bid)
                    new_bid_item.save()
                    messages.success(request, 'your bid is placed successfully 1.')
                    return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
                else:
                    messages.success(request, 'your bid must be higher than the current bid.')
                    return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
            except Exception as e:
                new_bid_item = Bid(list_object=list_object, user=user, bid=bid)
                new_bid_item.save()
                messages.success(request, 'your bid is placed successfully 2.')
                return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
    else:
        return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))


def status_listing(request):
    if request.method == "POST" and request.user.is_authenticated:
        listingid = request.POST["listingid"]
        status = request.POST["status"]
        list_object = Auction_listing.objects.get(pk=listingid)
        user = request.user
        if user == list_object.user:
            status_item = ListingStatus(list_object=list_object, status=status)
            status_item.save()
            return HttpResponseRedirect(reverse("auctions:index"))
        else:
            return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
    else:
        return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))

def comment_listing(request):
    if request.method == "POST" and request.user.is_authenticated:
        listingid = request.POST["listingid"]
        userid = request.POST["userid"]
        comment = request.POST["comment"]
        list_object = Auction_listing.objects.get(pk=listingid)
        user = User.objects.get(pk=userid)

        comment = Comment(list_object=list_object, user=user, comment=comment)
        comment.save()
        return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))
    else:
        return redirect(request.META.get('HTTP_REFERER', 'redirect_if_referer_not_found'))