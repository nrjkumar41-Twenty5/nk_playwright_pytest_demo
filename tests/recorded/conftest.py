"""Fixtures for recorded (codegen-generated) tests."""

from __future__ import annotations

import pytest
from playwright.sync_api import expect


@pytest.fixture(autouse=True)
def _recorded_defaults():
    """Generous timeouts so recorded tests tolerate loading delays."""
    expect.set_options(timeout=10_000)
