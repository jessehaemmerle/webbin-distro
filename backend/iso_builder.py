import asyncio
import os
import shutil
import subprocess
import tempfile
import logging
from typing import Dict, List, Optional
from datetime import datetime
from pathlib import Path

from backend.models import ISOConfigModel, BuildStatus, BuildLogModel
from backend.database import DatabaseManager

logger = logging.getLogger(__name__)

class ArchISOBuilder:
    def __init__(self):
        self.build_dir = Path("/tmp/arch_iso_builds")
        self.build_dir.mkdir(exist_ok=True)
        self.output_dir = Path("/app/frontend/public/downloads")
        self.output_dir.mkdir(exist_ok=True)

    async def build_iso(self, config: ISOConfigModel) -> bool:
        """Build an Arch Linux ISO with the specified configuration"""
        try:
            # Update status to building
            await DatabaseManager.update_iso_config(
                config.id, 
                {"status": BuildStatus.BUILDING, "progress": 0}
            )
            
            await self._log_build_step(config.id, "INFO", "Starting ISO build process")
            
            # Create build workspace
            build_workspace = self.build_dir / config.id
            build_workspace.mkdir(exist_ok=True)
            
            # Step 1: Prepare archiso environment (10%)
            await self._update_progress(config.id, 10)
            await self._log_build_step(config.id, "INFO", "Preparing archiso environment")
            await self._prepare_archiso_environment(build_workspace, config)
            
            # Step 2: Configure packages (25%)
            await self._update_progress(config.id, 25)
            await self._log_build_step(config.id, "INFO", "Configuring package list")
            await self._configure_packages(build_workspace, config)
            
            # Step 3: Configure user settings (40%)
            await self._update_progress(config.id, 40)
            await self._log_build_step(config.id, "INFO", "Configuring user settings")
            await self._configure_user_settings(build_workspace, config)
            
            # Step 4: Configure desktop environment (55%)
            await self._update_progress(config.id, 55)
            await self._log_build_step(config.id, "INFO", "Configuring desktop environment")
            await self._configure_desktop_environment(build_workspace, config)
            
            # Step 5: Build the ISO (85%)
            await self._update_progress(config.id, 70)
            await self._log_build_step(config.id, "INFO", "Building ISO image")
            iso_path = await self._build_iso_image(build_workspace, config)
            
            # Step 6: Finalize and cleanup (100%)
            await self._update_progress(config.id, 90)
            await self._log_build_step(config.id, "INFO", "Finalizing build")
            
            if iso_path and iso_path.exists():
                # Move ISO to public downloads directory
                final_iso_path = self.output_dir / f"{config.name.replace(' ', '_')}_{config.id[:8]}.iso"
                shutil.move(str(iso_path), str(final_iso_path))
                
                # Get file size
                file_size = self._format_file_size(final_iso_path.stat().st_size)
                
                # Update config with completion status
                await DatabaseManager.update_iso_config(config.id, {
                    "status": BuildStatus.COMPLETED,
                    "progress": 100,
                    "size": file_size,
                    "download_url": f"/downloads/{final_iso_path.name}"
                })
                
                await self._log_build_step(config.id, "INFO", f"ISO build completed successfully. Size: {file_size}")
                
                # Cleanup build workspace
                shutil.rmtree(build_workspace, ignore_errors=True)
                
                return True
            else:
                raise Exception("ISO file was not created")
                
        except Exception as e:
            logger.error(f"ISO build failed for config {config.id}: {str(e)}")
            await DatabaseManager.update_iso_config(config.id, {
                "status": BuildStatus.FAILED,
                "error_message": str(e)
            })
            await self._log_build_step(config.id, "ERROR", f"Build failed: {str(e)}")
            
            # Cleanup on failure
            build_workspace = self.build_dir / config.id
            if build_workspace.exists():
                shutil.rmtree(build_workspace, ignore_errors=True)
            
            return False

    async def _prepare_archiso_environment(self, workspace: Path, config: ISOConfigModel):
        """Prepare the archiso build environment"""
        # Copy archiso profile
        archiso_profile = workspace / "archiso_profile"
        
        # Simulate archiso setup (in real implementation, this would copy actual archiso files)
        await asyncio.sleep(2)  # Simulate work
        
        # Create necessary directories
        (archiso_profile / "airootfs").mkdir(parents=True, exist_ok=True)
        (archiso_profile / "packages.x86_64").touch()
        (archiso_profile / "profiledef.sh").touch()

    async def _configure_packages(self, workspace: Path, config: ISOConfigModel):
        """Configure the package list for the ISO"""
        packages_file = workspace / "archiso_profile" / "packages.x86_64"
        
        # Write selected packages to file
        with open(packages_file, "w") as f:
            for package in config.selected_packages:
                f.write(f"{package}\n")
        
        await asyncio.sleep(1)  # Simulate work

    async def _configure_user_settings(self, workspace: Path, config: ISOConfigModel):
        """Configure user settings and system configuration"""
        # Create user configuration script
        user_config_script = workspace / "archiso_profile" / "airootfs" / "root" / "customize_airootfs.sh"
        user_config_script.parent.mkdir(parents=True, exist_ok=True)
        
        with open(user_config_script, "w") as f:
            f.write("#!/bin/bash\n")
            f.write(f"# User configuration for {config.name}\n")
            f.write(f"echo 'HOSTNAME={config.user_config.hostname}' > /etc/hostname\n")
            f.write(f"ln -sf /usr/share/zoneinfo/{config.user_config.timezone} /etc/localtime\n")
            f.write(f"echo '{config.user_config.locale} UTF-8' > /etc/locale.gen\n")
            f.write("locale-gen\n")
        
        user_config_script.chmod(0o755)
        await asyncio.sleep(1)  # Simulate work

    async def _configure_desktop_environment(self, workspace: Path, config: ISOConfigModel):
        """Configure desktop environment if selected"""
        if config.desktop_environment and config.desktop_environment != "none":
            de_config_script = workspace / "archiso_profile" / "airootfs" / "root" / "setup_desktop.sh"
            
            with open(de_config_script, "w") as f:
                f.write("#!/bin/bash\n")
                f.write(f"# Desktop environment setup: {config.desktop_environment}\n")
                
                if config.desktop_environment == "gnome":
                    f.write("systemctl enable gdm\n")
                elif config.desktop_environment == "kde":
                    f.write("systemctl enable sddm\n")
                elif config.desktop_environment == "xfce":
                    f.write("systemctl enable lightdm\n")
            
            de_config_script.chmod(0o755)
        
        await asyncio.sleep(1)  # Simulate work

    async def _build_iso_image(self, workspace: Path, config: ISOConfigModel) -> Optional[Path]:
        """Build the actual ISO image"""
        try:
            # Simulate ISO building process
            await asyncio.sleep(5)  # Simulate the time-consuming build process
            
            # Create a dummy ISO file for demonstration
            iso_path = workspace / f"{config.name.replace(' ', '_')}.iso"
            
            # Create a minimal ISO-like file (in real implementation, this would be mkarchiso)
            with open(iso_path, "wb") as f:
                # Write some dummy data to simulate an ISO
                dummy_data = b"ARCH ISO " * 1000000  # ~8MB file
                f.write(dummy_data)
            
            return iso_path
            
        except Exception as e:
            logger.error(f"Failed to build ISO: {str(e)}")
            return None

    async def _update_progress(self, config_id: str, progress: int):
        """Update build progress"""
        await DatabaseManager.update_iso_config(config_id, {"progress": progress})

    async def _log_build_step(self, config_id: str, level: str, message: str, details: Dict = None):
        """Log a build step"""
        log_entry = BuildLogModel(
            iso_config_id=config_id,
            level=level,
            message=message,
            details=details or {}
        )
        await DatabaseManager.create_build_log(log_entry)

    def _format_file_size(self, size_bytes: int) -> str:
        """Format file size in human readable format"""
        if size_bytes < 1024:
            return f"{size_bytes} B"
        elif size_bytes < 1024**2:
            return f"{size_bytes/1024:.1f} KB"
        elif size_bytes < 1024**3:
            return f"{size_bytes/(1024**2):.1f} MB"
        else:
            return f"{size_bytes/(1024**3):.1f} GB"

# Global builder instance
iso_builder = ArchISOBuilder()