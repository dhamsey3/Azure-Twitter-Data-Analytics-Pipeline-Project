import azure.functions as func
import json

def main(msg: func.QueueMessage) -> None:
    tweet_data = json.loads(msg.get_body().decode('utf-8'))
    # Process tweet data
    print(f"Processed tweet from {tweet_data['user']['name']}: {tweet_data['text']}")
