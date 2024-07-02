from pathlib import Path
from django.shortcuts import render
from visits.models import PageVisit

this_dir = Path(__file__).resolve().parent


def home_page_view(request, *args, **kwargs):
    qs = PageVisit.objects.all()
    page_qs = PageVisit.objects.filter(path=request.path)
    my_title = "Hello World!"
    my_context = {
        "page_title": my_title,
        "page_visit_count": page_qs.count(),
        "total_visit": qs.count()
        }
    html_template = "home.html"
    PageVisit.objects.create(path=request.path)
    return render(request, html_template, my_context)
