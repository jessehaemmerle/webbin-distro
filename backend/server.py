from fastapi import FastAPI, APIRouter, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from typing import List

# Import our models and services
from backend.models import (
    ISOConfigRequest, ISOConfigModel, ISOConfigResponse, 
    PackageCategoryModel, ProfileModel, DesktopEnvironmentModel,
    BuildStatus, BuildLogModel
)
from backend.database import DatabaseManager
from backend.iso_builder import iso_builder

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ.get('MONGO_URL', 'mongodb://localhost:27017/')
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ.get('DB_NAME', 'arch_iso_builder')]

# Create the main app without a prefix
app = FastAPI(title="Arch ISO Builder API", version="1.0.0")

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Sample data for profiles and packages
SAMPLE_PROFILES = [
    {
        "id": "custom",
        "name": "Custom Configuration",
        "description": "Start from scratch and choose exactly what you need",
        "icon": "🛠️",
        "packages": ["base", "linux", "linux-firmware", "grub"]
    },
    {
        "id": "minimal",
        "name": "Minimal Installation",
        "description": "Bare minimum packages for a functional Arch system",
        "icon": "📦",
        "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "networkmanager", "sudo"]
    },
    {
        "id": "desktop",
        "name": "Desktop Workstation",
        "description": "Complete desktop environment with common applications",
        "icon": "🖥️",
        "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "gnome", "firefox", "libreoffice-fresh", "git", "vim"]
    },
    {
        "id": "developer",
        "name": "Developer Setup",
        "description": "Development tools and programming environments",
        "icon": "👨‍💻",
        "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "i3-wm", "git", "vim", "code", "docker", "nodejs", "python", "go"]
    },
    {
        "id": "gaming",
        "name": "Gaming Rig",
        "description": "Optimized for gaming with graphics drivers and gaming tools",
        "icon": "🎮",
        "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "kde-plasma", "steam", "lutris", "discord", "nvidia"]
    },
    {
        "id": "server",
        "name": "Server Installation",
        "description": "Headless server setup with essential services",
        "icon": "🖧",
        "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "openssh", "nginx", "docker", "git"]
    }
]

SAMPLE_PACKAGE_CATEGORIES = [
    {
        "id": "base",
        "name": "Base System",
        "description": "Essential packages for Arch Linux",
        "packages": [
            {"name": "base", "description": "Minimal package set to define a basic Arch Linux installation", "selected": True, "required": True},
            {"name": "base-devel", "description": "Basic tools to build Arch Linux packages", "selected": False, "required": False},
            {"name": "linux", "description": "The Linux kernel and modules", "selected": True, "required": True},
            {"name": "linux-firmware", "description": "Firmware files for Linux", "selected": True, "required": True},
            {"name": "grub", "description": "GNU GRand Unified Bootloader", "selected": True, "required": True},
            {"name": "efibootmgr", "description": "Linux user-space application to modify the EFI Boot Manager", "selected": False, "required": False},
            {"name": "networkmanager", "description": "Network connection manager and user applications", "selected": False, "required": False},
            {"name": "sudo", "description": "Give certain users the ability to run commands as root", "selected": False, "required": False},
        ]
    },
    {
        "id": "development",
        "name": "Development Tools",
        "description": "Programming and development packages",
        "packages": [
            {"name": "git", "description": "Fast distributed version control system", "selected": False, "required": False},
            {"name": "vim", "description": "Vi Improved text editor", "selected": False, "required": False},
            {"name": "code", "description": "Visual Studio Code", "selected": False, "required": False},
            {"name": "docker", "description": "Container platform", "selected": False, "required": False},
            {"name": "nodejs", "description": "JavaScript runtime", "selected": False, "required": False},
            {"name": "python", "description": "Python programming language", "selected": False, "required": False},
        ]
    }
]

SAMPLE_DESKTOP_ENVIRONMENTS = [
    {"id": "none", "name": "No Desktop Environment", "description": "Command line only", "selected": True},
    {"id": "gnome", "name": "GNOME", "description": "Modern, easy-to-use desktop environment", "selected": False},
    {"id": "kde", "name": "KDE Plasma", "description": "Feature-rich and customizable desktop", "selected": False},
    {"id": "xfce", "name": "XFCE", "description": "Lightweight, fast desktop environment", "selected": False},
    {"id": "i3", "name": "i3 Window Manager", "description": "Tiling window manager for advanced users", "selected": False}
]

# API Routes
@api_router.get("/")
async def root():
    return {"message": "Arch ISO Builder API v1.0"}

@api_router.get("/profiles", response_model=List[ProfileModel])
async def get_profiles():
    """Get available installation profiles"""
    return SAMPLE_PROFILES

@api_router.get("/packages", response_model=List[PackageCategoryModel]) 
async def get_package_categories():
    """Get available package categories and packages"""
    return SAMPLE_PACKAGE_CATEGORIES

@api_router.get("/desktop-environments", response_model=List[DesktopEnvironmentModel])
async def get_desktop_environments():
    """Get available desktop environments"""
    return SAMPLE_DESKTOP_ENVIRONMENTS

@api_router.post("/iso-configs", response_model=ISOConfigResponse)
async def create_iso_config(config_request: ISOConfigRequest, background_tasks: BackgroundTasks):
    """Create a new ISO configuration and start building"""
    try:
        # Create ISO configuration
        iso_config = ISOConfigModel(
            name=config_request.name,
            profile_id=config_request.profile_id,
            selected_packages=config_request.selected_packages,
            desktop_environment=config_request.desktop_environment,
            user_config=config_request.user_config,
            custom_settings=config_request.custom_settings or {}
        )
        
        # Save to database
        created_config = await DatabaseManager.create_iso_config(iso_config)
        
        # Start building ISO in background
        background_tasks.add_task(iso_builder.build_iso, created_config)
        
        return ISOConfigResponse(
            id=created_config.id,
            name=created_config.name,
            profile_id=created_config.profile_id,
            status=created_config.status,
            progress=created_config.progress,
            size=created_config.size,
            download_url=created_config.download_url,
            error_message=created_config.error_message,
            created_at=created_config.created_at,
            updated_at=created_config.updated_at
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create ISO configuration: {str(e)}")

@api_router.get("/iso-configs", response_model=List[ISOConfigResponse])
async def get_iso_configs():
    """Get all ISO configurations"""
    try:
        configs = await DatabaseManager.get_all_iso_configs()
        return [
            ISOConfigResponse(
                id=config.id,
                name=config.name,
                profile_id=config.profile_id,
                status=config.status,
                progress=config.progress,
                size=config.size,
                download_url=config.download_url,
                error_message=config.error_message,
                created_at=config.created_at,
                updated_at=config.updated_at
            ) for config in configs
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get ISO configurations: {str(e)}")

@api_router.get("/iso-configs/{config_id}", response_model=ISOConfigResponse)
async def get_iso_config(config_id: str):
    """Get specific ISO configuration"""
    config = await DatabaseManager.get_iso_config(config_id)
    if not config:
        raise HTTPException(status_code=404, detail="ISO configuration not found")
    
    return ISOConfigResponse(
        id=config.id,
        name=config.name,
        profile_id=config.profile_id,
        status=config.status,
        progress=config.progress,
        size=config.size,
        download_url=config.download_url,
        error_message=config.error_message,
        created_at=config.created_at,
        updated_at=config.updated_at
    )

@api_router.delete("/iso-configs/{config_id}")
async def delete_iso_config(config_id: str):
    """Delete ISO configuration"""
    success = await DatabaseManager.delete_iso_config(config_id)
    if not success:
        raise HTTPException(status_code=404, detail="ISO configuration not found")
    
    return {"message": "ISO configuration deleted successfully"}

@api_router.get("/iso-configs/{config_id}/logs", response_model=List[BuildLogModel])
async def get_build_logs(config_id: str):
    """Get build logs for specific ISO configuration"""
    logs = await DatabaseManager.get_build_logs(config_id)
    return logs

@api_router.get("/downloads/{filename}")
async def download_iso(filename: str):
    """Download ISO file"""
    file_path = Path("/app/frontend/public/downloads") / filename
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="File not found")
    
    return FileResponse(
        path=str(file_path),
        filename=filename,
        media_type="application/octet-stream"
    )

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()