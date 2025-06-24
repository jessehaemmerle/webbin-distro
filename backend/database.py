from motor.motor_asyncio import AsyncIOMotorClient
from backend.models import ISOConfigModel, BuildLogModel
import os
from typing import List, Optional
from datetime import datetime

# MongoDB connection
mongo_url = os.environ.get('MONGO_URL', 'mongodb://localhost:27017/')
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ.get('DB_NAME', 'arch_iso_builder')]

# Collections
iso_configs_collection = db.iso_configs
build_logs_collection = db.build_logs

class DatabaseManager:
    @staticmethod
    async def create_iso_config(iso_config: ISOConfigModel) -> ISOConfigModel:
        """Create a new ISO configuration"""
        result = await iso_configs_collection.insert_one(iso_config.dict())
        iso_config.id = str(result.inserted_id) if result.inserted_id else iso_config.id
        return iso_config

    @staticmethod
    async def get_iso_config(config_id: str) -> Optional[ISOConfigModel]:
        """Get ISO configuration by ID"""
        config = await iso_configs_collection.find_one({"id": config_id})
        return ISOConfigModel(**config) if config else None

    @staticmethod
    async def get_all_iso_configs(limit: int = 50) -> List[ISOConfigModel]:
        """Get all ISO configurations"""
        configs = await iso_configs_collection.find().sort("created_at", -1).limit(limit).to_list(limit)
        return [ISOConfigModel(**config) for config in configs]

    @staticmethod
    async def update_iso_config(config_id: str, update_data: dict) -> Optional[ISOConfigModel]:
        """Update ISO configuration"""
        update_data["updated_at"] = datetime.utcnow()
        result = await iso_configs_collection.update_one(
            {"id": config_id}, 
            {"$set": update_data}
        )
        if result.modified_count > 0:
            return await DatabaseManager.get_iso_config(config_id)
        return None

    @staticmethod
    async def delete_iso_config(config_id: str) -> bool:
        """Delete ISO configuration"""
        result = await iso_configs_collection.delete_one({"id": config_id})
        return result.deleted_count > 0

    @staticmethod
    async def create_build_log(build_log: BuildLogModel) -> BuildLogModel:
        """Create a build log entry"""
        await build_logs_collection.insert_one(build_log.dict())
        return build_log

    @staticmethod
    async def get_build_logs(config_id: str, limit: int = 100) -> List[BuildLogModel]:
        """Get build logs for a specific ISO configuration"""
        logs = await build_logs_collection.find(
            {"iso_config_id": config_id}
        ).sort("timestamp", -1).limit(limit).to_list(limit)
        return [BuildLogModel(**log) for log in logs]

# Import datetime after defining the class to avoid circular imports
from datetime import datetime