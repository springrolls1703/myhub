from django.http import HttpResponse
from django.shortcuts import render
from django.template.loader import render_to_string
from django import forms
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.urls import reverse
import random



from . import util
import markdown2

class entry(forms.Form):
    title = forms.CharField(label="title")
    description = forms.CharField(label="description")

def index(request):
    return render(request, "encyclopedia/index.html", {
        "entries": util.list_entries()
    })

def get_title(request, title):
    result = util.get_entry(title)
    if result != None:
        return render(request, "encyclopedia/title.html", {
            "result": markdown2.markdown(result),
            "title": title
        })
    else:
        return render(request, "encyclopedia/page_not_found.html")

def edit_page(request, title):
    result = util.get_entry(title)
    if result != None:
        return render(request, "encyclopedia/edit.html", {
            "result": result,
            "title": title
        })
    else:
        return render(request, "encyclopedia/page_not_found.html")
    

def search(request):
    if request.method == "POST":
        queries = request.POST["q"]
        all_entries = util.list_entries()
        search_result = []
        for i in range(len(all_entries)):
            if queries.lower() == all_entries[i].lower():
                url = reverse('wiki:title', kwargs={'title':queries})
                return HttpResponseRedirect(url)
            elif queries.lower() in all_entries[i].lower():
                search_result += [all_entries[i]]
        return render(request, "encyclopedia/search.html", {
        "result": search_result
        })

def create_new_page(request):    
    return render(request, "encyclopedia/new_page.html")

def save_request(request):
    if request.method == "POST":
        form = entry(request.POST)
        all_entries = util.list_entries()
        if form.is_valid():
            title = form.cleaned_data["title"]
            description = form.cleaned_data["description"]
            all_entries = util.list_entries()
            if title in all_entries:
                return render(request, "encyclopedia/page_existed.html")
            else:
                util.save_entry(title,description)
                url = "wiki:index"
                return HttpResponseRedirect(reverse(url))
        return render(request, "encyclopedia/new_page.html")

def save_content(request):
    if request.method == "POST":
        form = entry(request.POST)
        all_entries = util.list_entries()
        if form.is_valid():
            title = form.cleaned_data["title"]
            description = form.cleaned_data["description"]
            all_entries = util.list_entries()
            if title in all_entries:
                util.save_entry(title,description)
                url = reverse('wiki:title', kwargs={'title':title})
                return HttpResponseRedirect(url)
            else:
                render(request, "encyclopedia/page_not_found.html")
        return render(request, "encyclopedia/page_not_found.html")

def random_page(request):
    all_entries = util.list_entries()
    i = random.randint(0,len(all_entries)-1)
    random_entry = all_entries[i]
    result = util.get_entry(random_entry)
    return render(request, "encyclopedia/title.html", {
            "result": markdown2.markdown(result),
            "title": random_entry
    })
