from django.db import models
from django.urls import reverse


class PageVisit(models.Model):
    path = models.TextField()
    timestamp = models.DateTimeField(blank=True, auto_now=True)

    class Meta:
        verbose_name = "PageVisit"
        verbose_name_plural = "PageVisits"

    def __str__(self):
        return self.path

    def get_absolute_url(self):
        return reverse("PageVisit_detail", kwargs={"pk": self.pk})
