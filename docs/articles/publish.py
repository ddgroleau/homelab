import glob
import os
from simple_term_menu import TerminalMenu
import requests
import json as JSON

class Article:
    def __init__(self, article_file:str):
        self.filename:str = article_file
        self.id:int = None
        article_path = os.path.join(os.path.dirname(__file__), article_file)
        with open(article_path, "r") as file_stream:
            self.title :str = file_stream.readline()
            self.contents :str = file_stream.read().replace(self.title, "")
        with open("publish_log.json", "r") as publish_log:
            publish_log_json = JSON.loads(publish_log.read())
            existing_publish = publish_log_json.get(article_file)
            if existing_publish:
                self.id = existing_publish["id"]

    def publish_to_dev(self) -> requests.Response:
        exists = self.id != None
        api_uri = "https://dev.to/api/articles"
        if exists:
            api_uri += f"/{self.id}"
        api_key = os.getenv("FOREM_API_KEY")
        headers = {
            "accept": "application/vnd.forem.api-v1+json",
            "api-key": api_key
        }
        data = {
            "article": {
                "title": self.title.strip("# ").strip(),
                "published": True,
                "body_markdown": self.contents,
                "series":"Spare Parts - A Kubernetes Homelab",
                "tags": ["kubernetes", "homelab", "devops", "linux"]
            }
        }
        response : requests.Response = None
        if exists:
            print("Updating article...")
            response = requests.put(api_uri, json=data, headers=headers)
        else:
            print("Publishing article...")
            response = requests.post(api_uri, json=data, headers=headers)
        
        if response.status_code >= 200 and response.status_code < 300:
            self._update_publish_log(response)
        else:
            print("Failed to publish article. Status code:", response.status_code)
            print("Response:", response.text)

    def _update_publish_log(self, response:requests.Response):
        json = response.json()
        id = json["id"]
        url = json["url"]
        verb = "updated" if self.id else "published"
        print(f"Article {id} {verb} successfully! Read it at {url}")
        # Update the publish log with the article's ID and URL
        with open("publish_log.json", "r+") as publish_log:
            contents = JSON.loads(publish_log.read())
            contents[self.filename] = {
                "id": id,
                "url": url
            }
            publish_log.seek(0)
            publish_log.truncate()
            publish_log.write(JSON.dumps(contents, indent=2))


def main():
    articles = get_articles()
    article_file = ""
    while article_file not in articles:
        terminal_menu = TerminalMenu(articles, title="Select an article to publish:")
        menu_entry_index = terminal_menu.show()
        article_file = articles[menu_entry_index]
    article = Article(article_file=article_file)
    article.publish_to_dev()


def get_articles():
    articles = glob.glob(os.path.join(os.path.dirname(__file__), "*.md"))
    for i in range(len(articles)):
        articles[i] = os.path.basename(articles[i])
    articles.sort()
    return articles

if __name__=="__main__":
    main()

