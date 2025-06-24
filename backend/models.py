from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
import uuid
from enum import Enum

class BuildStatus(str, Enum):
    PENDING = "pending"
    BUILDING = "building" 
    COMPLETED = "completed"
    FAILED = "failed"

class PackageModel(BaseModel):
    name: str
    description: str
    selected: bool = False
    required: bool = False

class PackageCategoryModel(BaseModel):
    id: str
    name: str
    description: str
    packages: List[PackageModel]

class ProfileModel(BaseModel):
    id: str
    name: str
    description: str
    icon: str
    packages: List[str]

class DesktopEnvironmentModel(BaseModel):
    id: str
    name: str
    description: str
    selected: bool = False

class UserConfigModel(BaseModel):
    hostname: str = "archbox"
    username: str = "user"
    timezone: str = "UTC"
    locale: str = "en_US.UTF-8"
    keymap: str = "us"

class ISOConfigRequest(BaseModel):
    name: str
    profile_id: str
    selected_packages: List[str]
    desktop_environment: str
    user_config: UserConfigModel
    custom_settings: Optional[Dict[str, Any]] = {}

class ISOConfigModel(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    profile_id: str
    selected_packages: List[str]
    desktop_environment: str
    user_config: UserConfigModel
    custom_settings: Dict[str, Any] = {}
    status: BuildStatus = BuildStatus.PENDING
    progress: int = 0
    size: Optional[str] = None
    download_url: Optional[str] = None
    error_message: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class ISOConfigResponse(BaseModel):
    id: str
    name: str
    profile_id: str
    status: BuildStatus
    progress: int
    size: Optional[str]
    download_url: Optional[str]
    error_message: Optional[str]
    created_at: datetime
    updated_at: datetime

class BuildLogModel(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    iso_config_id: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    level: str  # INFO, WARNING, ERROR
    message: str
    details: Optional[Dict[str, Any]] = {}