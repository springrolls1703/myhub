from django.contrib.auth import authenticate, login, logout
from django.db import IntegrityError
from django.http import HttpResponse, HttpResponseRedirect, JsonResponse
from django.shortcuts import render
from django.urls import reverse
from django.core.paginator import Paginator
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
import json



from .models import User, Post, Profile


def new_post(request):
    if request.user.is_authenticated and request.method == "POST":
        post = request.POST["post"]
        user = request.user
        new_post = Post(user=user,post=post)
        new_post.save()
        selected_post = Post.objects.all()
        return HttpResponseRedirect(reverse("index"))
    else:
        return render(request, "network/index.html")

@csrf_exempt
@login_required
def edit_post(request,id):
    if request.user.is_authenticated and request.method == "PUT":
        try:
            post = Post.objects.get(pk=id)
        except Post.DoesNotExist:
            return JsonResponse({"error": "Email not found."}, status=404)
        data = json.loads(request.body)
        post.post = data["content"]
        post.save()
        return HttpResponse(status=204)
    else:
        return JsonResponse({
            "error": "GET or PUT request required."
        }, status=400)
        

def load(request):
    if request.user.is_authenticated:
        try:
            posts = Post.objects.all().order_by("-timestamp")
            paginator = Paginator(posts, 10)
            page_number = request.GET.get('page',1)
            page = paginator.get_page(page_number)
            page_content = {
                'num_page': paginator.num_pages
            }

            context = {
                'page': page_content,
                'posts': [p.serialize(request.user) for p in page],
                'requestid': request.user.id
            }
            return JsonResponse(context, safe=False)
        except Post.DoesNotExist:
            return JsonResponse({"error": "Post not found."}, status=404)
    else:
        render(request, "network/index.html")

def load_profile(request, id):
    try:
        user = User.objects.get(pk=id)
        profile = Profile.objects.get(user=user)
        return JsonResponse(profile.serialize(request.user), safe=False)
    except Profile.DoesNotExist:
        return JsonResponse({"error": "Profile not found."}, status=404)

def following_post(request):
    if request.user.is_authenticated:
        try:
            user = request.user
            prodfiles = user.Profile_follower.all()
            users = [profile.user for profile in profiles]
            posts = Post.objects.filter(user__in=users).order_by("-timestamp")
            paginator = Paginator(posts, 10)
            page_number = request.GET.get('page',1)
            page = paginator.get_page(page_number)
            page_content = {
                'num_page': paginator.num_pages
            }

            context = {
                'page': page_content,
                'posts': [p.serialize(request.user) for p in page],
                'requestid': request.user.id
            }
            return JsonResponse(context, safe=False)
        except Post.DoesNotExist:
            return JsonResponse({"error": "Post not found."}, status=404)
    else:
        render(request, "network/index.html")


def load_profile_post(request, id):
    if request.user.is_authenticated:
        try:
            user = User.objects.get(pk=id)
            posts = Post.objects.filter(user=user).order_by("-timestamp")
            paginator = Paginator(posts, 10)
            page_number = request.GET.get('page',1)
            page = paginator.get_page(page_number)
            page_content = {
                'num_page': paginator.num_pages
            }

            context = {
                'page': page_content,
                'posts': [p.serialize(request.user) for p in page],
                'requestid': request.user.id
            }
            return JsonResponse(context, safe=False)
        except Post.DoesNotExist:
            return JsonResponse({"error": "Post not found."}, status=404)
    else:
        render(request, "network/index.html")

def like_post(request, id):
    if request.user.is_authenticated:
        try:
            post = Post.objects.get(pk=id)
            user = request.user
            if (post in user.Liked.all()) == True:
                post.reaction.remove(user)
                like_num = Post.objects.get(pk=id).reaction.count()
                return JsonResponse(
                    {
                        "button": "Like",
                        "like_num": like_num
                }, safe=False)
            else:
                post.reaction.add(user)
                like_num = Post.objects.get(pk=id).reaction.count()
                return JsonResponse(
                    {
                        "button": "Unlike",
                        "like_num": like_num
                }, safe=False)
        except Post.DoesNotExist:
            JsonResponse({"error": "Post not found. 2"}, status=404)
    else: 
        return JsonResponse({"error": "Post not found. 3"}, status=404)
        


def follow(request, id):
    if request.user.is_authenticated:
        try:
            user = User.objects.get(pk=id)
            request_user = request.user
            profile = Profile.objects.get(user=user)
            if ((profile in request_user.Profile_follower.all()) == False) and (request_user != user):
                follower = request.user
                profile.follower.add(follower)
                return JsonResponse({"button": "Unfollow"}, safe=False)
            elif ((profile in request_user.Profile_follower.all()) == True) and (request_user != user):
                follower = request.user
                profile.follower.remove(follower)
                return JsonResponse({"button": "Follow"}, safe=False)
            else:
                return JsonResponse({"error": "Profile not found. 1"}, status=404)
        except Profile.DoesNotExist:
            JsonResponse({"error": "Post not found. 2"}, status=404)
    else: 
        return JsonResponse({"error": "Post not found. 3"}, status=404)

def following(request):
    if request.user.is_authenticated:
        try:
            user = request.user
            profiles = user.Profile_follower.all()
            user_set = [profile.user for profile in profiles]
            posts = Post.objects.filter(user__in=user_set)
            return JsonResponse([post.serialize(request.user) for post in posts], safe=False)
        except Post.DoesNotExist:
            return JsonResponse({"error": "Post not found."}, status=404)

def index(request):
    return render(request, "network/index.html")


def login_view(request):
    if request.method == "POST":

        # Attempt to sign user in
        username = request.POST["username"]
        password = request.POST["password"]
        user = authenticate(request, username=username, password=password)

        # Check if authentication successful
        if user is not None:
            login(request, user)
            return HttpResponseRedirect(reverse("index"))
        else:
            return render(request, "network/login.html", {
                "message": "Invalid username and/or password."
            })
    else:
        return render(request, "network/login.html")


def logout_view(request):
    logout(request)
    return HttpResponseRedirect(reverse("index"))


def register(request):
    if request.method == "POST":
        username = request.POST["username"]
        email = request.POST["email"]

        # Ensure password matches confirmation
        password = request.POST["password"]
        confirmation = request.POST["confirmation"]
        if password != confirmation:
            return render(request, "network/register.html", {
                "message": "Passwords must match."
            })

        # Attempt to create new user
        try:
            user = User.objects.create_user(username, email, password)
            profile = Profile(user=user)
            user.save()
            profile.save()
        except IntegrityError:
            return render(request, "network/register.html", {
                "message": "Username already taken."
            })
        login(request, user)
        return HttpResponseRedirect(reverse("index"))
    else:
        return render(request, "network/register.html")
