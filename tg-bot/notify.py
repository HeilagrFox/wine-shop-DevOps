#!/usr/bin/env python3

import os
import sys
import urllib.parse
import urllib.request
import json


def main():
    if len(sys.argv) < 6:
        print(
            "❌ Usage: notify.py <status> <pipeline_name> <pipeline_url> <branch> <commit>",
            file=sys.stderr,
        )
        sys.exit(1)

    status = sys.argv[1]
    pipeline_name = sys.argv[2]
    pipeline_url = sys.argv[3]
    branch = sys.argv[4]
    commit = sys.argv[5]

    status_map = {
        "success": "✅ SUCCESS",
        "failed": "❌ FAILED",
        "canceled": "⚠️ CANCELED",
    }
    status_text = status_map.get(status.lower(), f"❓ UNKNOWN ({status})")

    tg_token = os.getenv("TG_BOT_TOKEN", "").strip()
    tg_chat_id = os.getenv("TG_CHAT_ID", "").strip()

    if not tg_token:
        print("❌ Error: TG_BOT_TOKEN environment variable is not set", file=sys.stderr)
        sys.exit(1)
    if not tg_chat_id:
        print("❌ Error: TG_CHAT_ID environment variable is not set", file=sys.stderr)
        sys.exit(1)

    if not tg_token.replace(":", "").replace("_", "").replace("-", "").isalnum():
        print(
            f"❌ Error: TG_BOT_TOKEN has invalid format (length: {len(tg_token)})",
            file=sys.stderr,
        )
        sys.exit(1)

    message = (
        f"🔧 {pipeline_name}\n"
        f"Status: {status_text}\n"
        f"Branch: {branch}\n"
        f"Commit: {commit[:7]}\n"
        f"Link: {pipeline_url}"
    )

    api_url = f"https://api.telegram.org/bot{tg_token}/sendMessage"

    payload = urllib.parse.urlencode(
        {
            "chat_id": tg_chat_id,
            "text": message,
            "parse_mode": "none",
            "disable_web_page_preview": "true",
        }
    ).encode("utf-8")

    request = urllib.request.Request(
        api_url,
        data=payload,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            result = json.loads(response.read().decode("utf-8"))
            if result.get("ok"):
                print(f"Notification sent successfully to chat {tg_chat_id}")
                sys.exit(0)
            else:
                print(
                    f"Telegram API error: {result.get('description', 'Unknown error')}",
                    file=sys.stderr,
                )
                sys.exit(2)
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8", errors="ignore")
        print(f"HTTP {e.code}: {error_body}", file=sys.stderr)
        sys.exit(3)
    except urllib.error.URLError as e:
        print(f"Network error: {e.reason}", file=sys.stderr)
        sys.exit(4)
    except Exception as e:
        print(f"Unexpected error: {type(e).__name__}: {e}", file=sys.stderr)
        sys.exit(99)


if __name__ == "__main__":
    main()
