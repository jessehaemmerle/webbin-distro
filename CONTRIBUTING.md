# Contributing to Custom Debian Distribution

Thank you for your interest in contributing to our custom Debian distribution! This document provides guidelines for contributing to the project.

## Ways to Contribute

### 1. Bug Reports
- Use GitHub Issues to report bugs
- Include detailed steps to reproduce
- Provide system information and logs
- Check if the issue already exists

### 2. Feature Requests
- Open a GitHub Issue with the "enhancement" label
- Describe the feature and its use case
- Discuss implementation approaches

### 3. Code Contributions
- Fork the repository
- Create a feature branch
- Make your changes
- Test thoroughly
- Submit a pull request

### 4. Documentation
- Improve existing documentation
- Add missing documentation
- Fix typos and formatting
- Translate documentation

### 5. Testing
- Test new releases
- Report compatibility issues
- Verify installation procedures
- Test on different hardware

## Development Setup

### Prerequisites
- Debian 12 or Ubuntu 22.04+ system
- 8GB+ RAM
- 20GB+ free disk space
- Internet connection

### Setup
```bash
# Clone the repository
git clone https://github.com/your-org/custom-debian-distribution.git
cd custom-debian-distribution

# Install build dependencies
sudo apt update
sudo apt install -y live-build debootstrap squashfs-tools xorriso isolinux syslinux-efi

# Build the distribution
./scripts/build.sh

# Test in VM
./scripts/test-vm.sh
```

## Code Guidelines

### Shell Scripts
- Use `#!/bin/bash` shebang
- Enable strict mode: `set -e`
- Use meaningful variable names
- Add comments for complex logic
- Follow Google Shell Style Guide

### Configuration Files
- Use consistent indentation (2 spaces)
- Comment configuration options
- Validate syntax before committing
- Test configurations thoroughly

### Documentation
- Use Markdown format
- Keep lines under 80 characters
- Use clear headings and structure
- Include code examples where helpful

## Commit Guidelines

### Commit Messages
Follow conventional commit format:
```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `build`: Build system changes

Examples:
```
feat(sway): add custom keybindings configuration

Add predefined keybindings for common applications and
window management operations to improve user experience.

Closes #123

fix(build): resolve package dependency conflict

The multimedia packages were conflicting with system audio.
Updated package list to use compatible versions.

Fixes #456
```

### Branch Naming
- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

## Pull Request Process

### Before Submitting
1. Test your changes thoroughly
2. Update documentation if needed
3. Add/update tests as appropriate
4. Ensure all checks pass
5. Update CHANGELOG.md if applicable

### PR Description
Include:
- Clear description of changes
- Motivation and context
- Testing performed
- Screenshots/videos if UI changes
- Breaking changes (if any)

### Review Process
1. Automated checks must pass
2. At least one maintainer review required
3. Address feedback promptly
4. Maintainer will merge when approved

## Testing

### Build Testing
```bash
# Clean build
./scripts/build.sh

# Test basic functionality
./scripts/test-vm.sh
```

### Manual Testing
- Boot from USB on real hardware
- Test installation process
- Verify all included applications work
- Check hardware compatibility

### Automated Testing
- GitHub Actions run on all PRs
- Basic boot tests
- Package installation verification
- Configuration validation

## Package Management

### Adding Packages
1. Add package to appropriate list in `config/package-lists/`
2. Test build and functionality
3. Update documentation
4. Consider security implications

### Removing Packages
1. Check for dependencies
2. Update package lists
3. Test build
4. Document breaking changes

### Custom Packages
- Prefer official Debian packages
- Document source for third-party packages
- Ensure proper licensing
- Test thoroughly

## Release Process

### Version Numbering
Follow semantic versioning (semver):
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes

### Release Checklist
- [ ] Update version numbers
- [ ] Update CHANGELOG.md
- [ ] Test release candidate
- [ ] Create git tag
- [ ] Build and publish ISO
- [ ] Update documentation
- [ ] Announce release

## Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn and grow
- Follow the project's code of conduct

### Communication
- Use GitHub Issues for bugs and features
- Use Discussions for questions and ideas
- Be clear and concise
- Provide context and examples
- Search existing issues before creating new ones

## Getting Help

### Documentation
- [Build Guide](docs/BUILD.md)
- [User Guide](docs/USER.md)
- [Design Document](DESIGN.md)

### Community
- GitHub Discussions
- Issue tracker
- Project wiki

### Maintainers
Current maintainers:
- @maintainer1
- @maintainer2

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation
- GitHub contributor graphs

Thank you for contributing to making this distribution better for everyone!
