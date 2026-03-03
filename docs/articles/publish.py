import glob
import os
import sys
from simple_term_menu import TerminalMenu
import requests

def main():
    publish_article()

def publish_article():
    article = ""
    articles = get_unpublished_articles()

    while article not in articles:
        terminal_menu = TerminalMenu(articles, title="Select an article to publish:")
        menu_entry_index = terminal_menu.show()
        article = articles[menu_entry_index]

    article_path = os.path.join(os.path.dirname(__file__), article)
    article_title = open(article_path, "r").readline()
    article_contents = open(article_path, "r").read().replace(article_title, "")

    print("Publishing article...")
    response = publish_to_dev(article_title, article_contents)

    if response.status_code == 201:
        json = response.json()
        id = json["id"]
        url = json["url"]
        print(f"Article {id} published successfully! read it at {url}")
        with open("publish_log", "a") as publish_log:
            publish_log.write(str(id) + "\t" +article + "\n")
    else:
        print("Failed to publish article. Status code:", response.status_code)
        print("Response:", response.text)

def get_unpublished_articles() -> list:
    articles = glob.glob(os.path.join(os.path.dirname(__file__), "*.md"))
    
    # Remove the directory from the article paths
    for i in range(len(articles)):
        articles[i] = os.path.basename(articles[i])
    
    # Filter out articles that have already been published
    articles = list(filter(lambda x: x not in open("publish_log", "r").read(), articles))
    if len(articles) == 0:
        print("No articles to publish.")
        sys.exit(0)
    
    articles.sort()
    return articles

def publish_to_dev(article_title: str, article_contents: str) -> requests.Response:
    api_uri = "https://dev.to/api/articles"
    api_key = os.getenv("FOREM_API_KEY")
    headers = {
        "accept": "application/vnd.forem.api-v1+json",
        "api-key": api_key
    }
    data = {
        "article": {
            "title": article_title.strip("# ").strip(),
            "published": True,
            "body_markdown": article_contents,
            "series":"Spare Parts - A Kubernetes Homelab",
            "tags": ["kubernetes", "homelab", "devops", "linux"]
        }
    }
    return requests.post(api_uri, json=data, headers=headers)

if __name__=="__main__":
    main()
