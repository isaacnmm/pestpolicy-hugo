import requests
from bs4 import BeautifulSoup
import os
import re
from urllib.parse import urljoin, urlparse

def is_internal(url, base_url):
    return urlparse(url).netloc == urlparse(base_url).netloc or url.startswith('/')

def check_link(url, base_url, visited):
    if url in visited:
        return
    visited.add(url)

    try:
        if is_internal(url, base_url) or urlparse(url).scheme in ['http', 'https']:
            print(f"Checking: {url}")
            response = requests.get(url, timeout=10, stream=True)
            response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
            content_type = response.headers.get('Content-Type', '')
            if 'text/html' in content_type:
                soup = BeautifulSoup(response.text, 'html.parser')
                for link in soup.find_all('a', href=True):
                    href = link['href']
                    absolute_url = urljoin(url, href)
                    check_link(absolute_url, base_url, visited)
        else:
            print(f"Skipping non-HTTP/HTTPS URL: {url}")
    except requests.exceptions.RequestException as e:
        print(f"Broken link found on {base_url}: {url} - Error: {e}")
    except Exception as e:
        print(f"Error checking {url} from {base_url}: {e}")

def crawl_site(base_url):
    visited = set()
    check_link(base_url, base_url, visited)

if __name__ == "__main__":
    base_url = "https://pestpolicy.com/"  # Replace with your live website URL
    crawl_site(base_url)
    print("\nBroken link check complete.")