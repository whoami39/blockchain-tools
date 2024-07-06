# - - - - - - - - - - - - - - - - - - - - - - - #
#                                               #
# Join Telegram: https://t.me/+ZOQ2jcLKI3hkNjFl #
#                                               #
# - - - - - - - - - - - - - - - - - - - - - - - #

import asyncio
import random
import requests
import json
import logging
from config import *

logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(asctime)s | %(message)s')
logger = logging.getLogger(__name__)

UA_LIST = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (iPad; CPU OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 OPR/78.0.4093.184",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"
]

class DiscordSender:
    def __init__(self, token, channel_id, titan_address):
        self.token = token
        self.channel_id = channel_id
        self.titan_address = titan_address
        self.user_agent = random.choice(UA_LIST)

    async def send_message(self, message):
        url = f"https://discordapp.com/api/channels/{self.channel_id}/messages"
        headers = {
            "Authorization": self.token,
            "Content-Type": "application/json",
            "User-Agent": self.user_agent
        }
        data = {
            "content": message
        }
        response = requests.post(url, headers=headers, data=json.dumps(data))
        if response.status_code == 200:
            logger.info(f"Message sent to channel {self.channel_id}")
        else:
            logger.error(f"Code: {response.status_code} Error: {json.loads(response.text)}")

    async def request_loop(self):
        while True:
            await self.send_message(f"$request {self.titan_address}")
            logger.info(f"Request sent to channel {self.channel_id} for address {self.titan_address}")

            next_interval = BASE_INTERVAL + random.randint(0, MAX_RANDOM_DELAY)
            logger.info(f"Next request for token ending with ...{self.token[-4:]} in {next_interval} seconds")
            await asyncio.sleep(next_interval)

async def run_sender(config):
    sender = DiscordSender(config['dc_token'], config['dc_channel_id'], config['titan_address'])
    await sender.request_loop()

async def main():
    tasks = []
    for config in DC_AUTO_SEND_CONFIG:
        if config['dc_token']:
            tasks.append(run_sender(config))
        else:
            logger.warning(f"Skipping account with empty token for address {config['titan_address']}")
    
    if tasks:
        await asyncio.gather(*tasks)
    else:
        logger.error("No valid accounts to run. Please check your DC_AUTO_SEND_CONFIG.")

if __name__ == "__main__":
    asyncio.run(main())
