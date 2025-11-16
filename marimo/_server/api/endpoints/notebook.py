# Copyright 2024 Marimo. All rights reserved.
"""API endpoint for loading notebook configuration in SPA mode."""
from __future__ import annotations

from typing import TYPE_CHECKING, Any

from starlette.responses import JSONResponse

from marimo import _loggers
from marimo._server.api.deps import AppState
from marimo._server.router import APIRouter
from marimo._server.templates.templates import get_mount_config_dict

if TYPE_CHECKING:
    from starlette.requests import Request

LOGGER = _loggers.marimo_logger()

# Router for notebook loading API
router = APIRouter()


@router.get("/api/notebook/load/{file_path:path}")
async def load_notebook(request: Request) -> JSONResponse:
    """
    Load notebook configuration for SPA routing.

    This endpoint returns the mount configuration as JSON instead of
    rendering a full HTML page. The frontend will use this to initialize
    the notebook in a tab.

    Note: This endpoint does not require authentication as it is designed
    to run in a secured environment.

    Parameters:
        file_path: Path to the notebook file (e.g., "projects/analysis.py")

    Returns:
        JSONResponse with notebook configuration:
        {
            "filename": str,
            "mode": "edit" | "read",
            "version": str,
            "serverToken": str,
            "config": {...},
            "configOverrides": {...},
            "appConfig": {...},
            "view": {...},
            "fileKey": str
        }

    Responses:
        200:
            description: Notebook configuration loaded successfully
            content:
                application/json:
                    schema:
                        type: object
        404:
            description: Notebook file not found
    """
    app_state = AppState(request)
    file_path = str(request.path_params["file_path"])

    LOGGER.debug(f"Loading notebook configuration for: {file_path}")

    # Use the file path as the file key
    file_key = file_path

    # Get the app manager for this file
    try:
        app_manager = app_state.session_manager.app_manager(file_key)
    except Exception as e:
        LOGGER.error(f"Failed to get app manager for {file_key}: {e}")
        return JSONResponse(
            status_code=404,
            content={"error": f"Notebook not found: {file_path}"}
        )

    # Get configuration managers
    config_manager = app_state.config_manager_at_file(file_key)
    app_config = app_manager.app.config

    # Build the mount configuration (same as what goes in __MARIMO_MOUNT_CONFIG__)
    mount_config = get_mount_config_dict(
        filename=app_manager.filename,
        mode=app_state.mode,
        server_token=app_state.skew_protection_token,
        user_config=config_manager.get_user_config(),
        config_overrides=config_manager.get_config_overrides(),
        app_config=app_config,
        remote_url=app_state.remote_url,
    )

    # Add the file key so frontend knows which file this is
    mount_config["fileKey"] = file_key

    LOGGER.debug(f"Successfully loaded configuration for: {file_path}")

    return JSONResponse(mount_config)
