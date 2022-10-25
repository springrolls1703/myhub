from django.urls import path

from . import views

app_name = "wiki"
urlpatterns = [
    path("", views.index, name="index"),
    path("wiki/<str:title>/", views.get_title, name="title"),
    path("search", views.search, name="search"),
    path("new-page", views.create_new_page, name="new-page"),
    path("save-entry", views.save_request, name="save-request"),
    path("wiki/<str:title>/edit", views.edit_page, name="edit_page"),
    path("save-content", views.save_content, name="save-content"),
    path("random-page", views.random_page, name="random-page")
]
