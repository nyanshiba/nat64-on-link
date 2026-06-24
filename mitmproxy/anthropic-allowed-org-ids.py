"""
Anthropic 公式ドキュメント（テナント制限）に基づき、
  claude.ai / api.anthropic.com / claude.com / anthropic.com
へのリクエストに anthropic-allowed-org-ids ヘッダーが存在しない、
または指定の Org ID が含まれていない場合は 403 で落とす。

cf. https://support.claude.com/en/articles/13198485
"""

from mitmproxy import http

TARGET_FQDNS = frozenset(
    {
        "claude.ai",
        "api.anthropic.com",
        "claude.com",
        "anthropic.com",
    }
)

ALLOWED_ORG_IDS: frozenset[str] = frozenset(
    {
        "550e8400-e29b-41d4-a716-446655440000",
        "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
    }
)

HEADER_NAME = "anthropic-allowed-org-ids"


def _is_target(host: str) -> bool:
    return host.lower() in TARGET_FQDNS


def request(flow: http.HTTPFlow) -> None:
    host = flow.request.pretty_host

    if not _is_target(host):
        return

    raw_header: str = flow.request.headers.get(HEADER_NAME, "")
    present_ids = {v.strip() for v in raw_header.split(",") if v.strip()}
    matched = present_ids & ALLOWED_ORG_IDS

    if matched:
        return

    import json

    body = json.dumps(
        {
            "type": "error",
            "error": {
                "type": "permission_error",
                "message": "Access restricted by network policy. Contact IT Administrator.",
                "error_code": "tenant_restriction_violation",
            },
        },
        ensure_ascii=False,
    )

    flow.response = http.Response.make(
        403,
        body,
        {"Content-Type": "application/json; charset=utf-8"},
    )
