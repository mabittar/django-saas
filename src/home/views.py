from pathlib import Path
from django.shortcuts import render
from visits.models import PageVisit

this_dir = Path(__file__).resolve().parent


def home_page_view(request, *args, **kwargs):
    queryset = PageVisit.objects.all()
    my_title = "Hello World!"
    my_context = {
        "page_title": my_title,
        "queryset": queryset
        }
    html_template = "home.html"
    PageVisit.objects.create()
    return render(request, html_template, my_context)
