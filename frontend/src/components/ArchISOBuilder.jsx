import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Checkbox } from './ui/checkbox';
import { ScrollArea } from './ui/scroll-area';
import { Separator } from './ui/separator';
import { Download, Settings, Package, Users, Monitor, Server, Gamepad2, Code, HardDrive, Play, CheckCircle, Clock, AlertCircle } from 'lucide-react';
import { mockProfiles, mockPackageCategories, mockDesktopEnvironments, mockUserConfig, mockISOConfigs } from '../mock/data';
import { useToast } from '../hooks/use-toast';

const ArchISOBuilder = () => {
  const [currentTab, setCurrentTab] = useState('profiles');
  const [selectedProfile, setSelectedProfile] = useState(null);
  const [packageCategories, setPackageCategories] = useState(mockPackageCategories);
  const [userConfig, setUserConfig] = useState(mockUserConfig);
  const [desktopEnvironments, setDesktopEnvironments] = useState(mockDesktopEnvironments);
  const [buildProgress, setBuildProgress] = useState(0);
  const [isBuilding, setIsBuilding] = useState(false);
  const [isoConfigs, setISOConfigs] = useState(mockISOConfigs);
  const { toast } = useToast();

  const getProfileIcon = (profileId) => {
    const icons = {
      minimal: '📦',
      desktop: '🖥️',
      developer: '👨‍💻',
      gaming: '🎮',
      server: '🖧'
    };
    return icons[profileId] || '📦';
  };

  const selectProfile = (profile) => {
    setSelectedProfile(profile);
    // Auto-select packages based on profile
    const updatedCategories = packageCategories.map(category => ({
      ...category,
      packages: category.packages.map(pkg => ({
        ...pkg,
        selected: profile.packages.includes(pkg.name) || pkg.required
      }))
    }));
    setPackageCategories(updatedCategories);
    
    toast({
      title: "Profile Selected",
      description: `${profile.name} profile has been applied with ${profile.packages.length} packages.`,
    });
  };

  const togglePackage = (categoryId, packageName) => {
    setPackageCategories(categories => 
      categories.map(category => 
        category.id === categoryId 
          ? {
              ...category,
              packages: category.packages.map(pkg => 
                pkg.name === packageName && !pkg.required
                  ? { ...pkg, selected: !pkg.selected }
                  : pkg
              )
            }
          : category
      )
    );
  };

  const selectDesktopEnvironment = (deId) => {
    setDesktopEnvironments(des => 
      des.map(de => ({ ...de, selected: de.id === deId }))
    );
  };

  const getSelectedPackages = () => {
    return packageCategories.flatMap(category => 
      category.packages.filter(pkg => pkg.selected).map(pkg => pkg.name)
    );
  };

  const startBuild = () => {
    setIsBuilding(true);
    setBuildProgress(0);
    
    // Simulate build progress
    const interval = setInterval(() => {
      setBuildProgress(prev => {
        if (prev >= 100) {
          clearInterval(interval);
          setIsBuilding(false);
          toast({
            title: "ISO Build Complete!",
            description: "Your custom Arch Linux ISO is ready for download.",
          });
          
          // Add to ISO configs list
          const newConfig = {
            id: Date.now().toString(),
            name: selectedProfile ? selectedProfile.name : 'Custom Configuration',
            profile: selectedProfile?.id || 'custom',
            createdAt: new Date().toISOString(),
            status: 'completed',
            size: `${(Math.random() * 2 + 1).toFixed(1)} GB`,
            downloadUrl: `/downloads/custom-${Date.now()}.iso`
          };
          setISOConfigs(prev => [newConfig, ...prev]);
          
          return 100;
        }
        return prev + Math.random() * 15;
      });
    }, 500);
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'completed': return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'building': return <Clock className="h-4 w-4 text-blue-500" />;
      case 'failed': return <AlertCircle className="h-4 w-4 text-red-500" />;
      default: return <Clock className="h-4 w-4 text-gray-500" />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-6xl font-bold text-white mb-4 bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">
            Arch ISO Builder
          </h1>
          <p className="text-xl text-gray-300 max-w-2xl mx-auto">
            Create custom Arch Linux installation ISOs with your preferred packages, desktop environments, and configurations.
          </p>
        </div>

        <Tabs value={currentTab} onValueChange={setCurrentTab} className="w-full">
          <TabsList className="grid w-full grid-cols-5 mb-8 bg-slate-800 border-slate-700">
            <TabsTrigger value="profiles" className="data-[state=active]:bg-purple-600">
              <Settings className="h-4 w-4 mr-2" />
              Profiles
            </TabsTrigger>
            <TabsTrigger value="packages" className="data-[state=active]:bg-purple-600">
              <Package className="h-4 w-4 mr-2" />
              Packages
            </TabsTrigger>
            <TabsTrigger value="desktop" className="data-[state=active]:bg-purple-600">
              <Monitor className="h-4 w-4 mr-2" />
              Desktop
            </TabsTrigger>
            <TabsTrigger value="user" className="data-[state=active]:bg-purple-600">
              <Users className="h-4 w-4 mr-2" />
              User Setup
            </TabsTrigger>
            <TabsTrigger value="build" className="data-[state=active]:bg-purple-600">
              <Play className="h-4 w-4 mr-2" />
              Build
            </TabsTrigger>
          </TabsList>

          {/* Profiles Tab */}
          <TabsContent value="profiles" className="space-y-6">
            <Card className="bg-slate-800 border-slate-700">
              <CardHeader>
                <CardTitle className="text-white">Choose a Profile</CardTitle>
                <CardDescription>
                  Start with a pre-configured profile or create a custom configuration
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {mockProfiles.map((profile) => (
                    <Card 
                      key={profile.id}
                      className={`cursor-pointer transition-all duration-300 hover:scale-105 border-2 ${
                        selectedProfile?.id === profile.id 
                          ? 'border-purple-500 bg-purple-500/10' 
                          : 'border-slate-600 bg-slate-700 hover:border-slate-500'
                      }`}
                      onClick={() => selectProfile(profile)}
                    >
                      <CardContent className="p-6 text-center">
                        <div className="text-4xl mb-3">{profile.icon}</div>
                        <h3 className="text-lg font-semibold text-white mb-2">{profile.name}</h3>
                        <p className="text-sm text-gray-400 mb-4">{profile.description}</p>
                        <Badge variant="secondary" className="bg-slate-600">
                          {profile.packages.length} packages
                        </Badge>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Packages Tab */}
          <TabsContent value="packages" className="space-y-6">
            <Card className="bg-slate-800 border-slate-700">
              <CardHeader>
                <CardTitle className="text-white">Package Selection</CardTitle>
                <CardDescription>
                  Choose packages to include in your ISO. Required packages cannot be deselected.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ScrollArea className="h-96">
                  {packageCategories.map((category) => (
                    <div key={category.id} className="mb-6">
                      <h3 className="text-lg font-semibold text-white mb-2">{category.name}</h3>
                      <p className="text-sm text-gray-400 mb-3">{category.description}</p>
                      <div className="space-y-2">
                        {category.packages.map((pkg) => (
                          <div key={pkg.name} className="flex items-center space-x-3 p-2 rounded-lg bg-slate-700">
                            <Checkbox
                              checked={pkg.selected}
                              disabled={pkg.required}
                              onCheckedChange={() => togglePackage(category.id, pkg.name)}
                              className="data-[state=checked]:bg-purple-600"
                            />
                            <div className="flex-1">
                              <div className="flex items-center gap-2">
                                <span className="text-white font-medium">{pkg.name}</span>
                                {pkg.required && <Badge variant="destructive" className="text-xs">Required</Badge>}
                              </div>
                              <p className="text-sm text-gray-400">{pkg.description}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                      <Separator className="mt-4 bg-slate-600" />
                    </div>
                  ))}
                </ScrollArea>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Desktop Environment Tab */}
          <TabsContent value="desktop" className="space-y-6">
            <Card className="bg-slate-800 border-slate-700">
              <CardHeader>
                <CardTitle className="text-white">Desktop Environment</CardTitle>
                <CardDescription>
                  Select a desktop environment for your Arch installation
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {desktopEnvironments.map((de) => (
                    <Card 
                      key={de.id}
                      className={`cursor-pointer transition-all duration-300 hover:scale-105 border-2 ${
                        de.selected 
                          ? 'border-purple-500 bg-purple-500/10' 
                          : 'border-slate-600 bg-slate-700 hover:border-slate-500'
                      }`}
                      onClick={() => selectDesktopEnvironment(de.id)}
                    >
                      <CardContent className="p-4">
                        <h3 className="text-lg font-semibold text-white mb-2">{de.name}</h3>
                        <p className="text-sm text-gray-400">{de.description}</p>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* User Setup Tab */}
          <TabsContent value="user" className="space-y-6">
            <Card className="bg-slate-800 border-slate-700">
              <CardHeader>
                <CardTitle className="text-white">User Configuration</CardTitle>
                <CardDescription>
                  Configure system settings and user accounts
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <Label htmlFor="hostname" className="text-white">Hostname</Label>
                    <Input
                      id="hostname"
                      value={userConfig.hostname}
                      onChange={(e) => setUserConfig(prev => ({ ...prev, hostname: e.target.value }))}
                      className="bg-slate-700 border-slate-600 text-white"
                    />
                  </div>
                  <div>
                    <Label htmlFor="username" className="text-white">Username</Label>
                    <Input
                      id="username"
                      value={userConfig.username}
                      onChange={(e) => setUserConfig(prev => ({ ...prev, username: e.target.value }))}
                      className="bg-slate-700 border-slate-600 text-white"
                    />
                  </div>
                  <div>
                    <Label htmlFor="timezone" className="text-white">Timezone</Label>
                    <Select value={userConfig.timezone} onValueChange={(value) => setUserConfig(prev => ({ ...prev, timezone: value }))}>
                      <SelectTrigger className="bg-slate-700 border-slate-600 text-white">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent className="bg-slate-700 border-slate-600">
                        <SelectItem value="UTC">UTC</SelectItem>
                        <SelectItem value="America/New_York">America/New_York</SelectItem>
                        <SelectItem value="Europe/London">Europe/London</SelectItem>
                        <SelectItem value="Asia/Tokyo">Asia/Tokyo</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="locale" className="text-white">Locale</Label>
                    <Select value={userConfig.locale} onValueChange={(value) => setUserConfig(prev => ({ ...prev, locale: value }))}>
                      <SelectTrigger className="bg-slate-700 border-slate-600 text-white">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent className="bg-slate-700 border-slate-600">
                        <SelectItem value="en_US.UTF-8">en_US.UTF-8</SelectItem>
                        <SelectItem value="es_ES.UTF-8">es_ES.UTF-8</SelectItem>
                        <SelectItem value="fr_FR.UTF-8">fr_FR.UTF-8</SelectItem>
                        <SelectItem value="de_DE.UTF-8">de_DE.UTF-8</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Build Tab */}
          <TabsContent value="build" className="space-y-6">
            <Card className="bg-slate-800 border-slate-700">
              <CardHeader>
                <CardTitle className="text-white">Build Configuration</CardTitle>
                <CardDescription>
                  Review your configuration and build your custom Arch ISO
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Configuration Summary */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="bg-slate-700 p-4 rounded-lg">
                    <h4 className="text-white font-semibold mb-2">Profile</h4>
                    <p className="text-gray-300">{selectedProfile?.name || 'Custom'}</p>
                  </div>
                  <div className="bg-slate-700 p-4 rounded-lg">
                    <h4 className="text-white font-semibold mb-2">Packages</h4>
                    <p className="text-gray-300">{getSelectedPackages().length} selected</p>
                  </div>
                  <div className="bg-slate-700 p-4 rounded-lg">
                    <h4 className="text-white font-semibold mb-2">Desktop</h4>
                    <p className="text-gray-300">{desktopEnvironments.find(de => de.selected)?.name}</p>
                  </div>
                </div>

                {/* Build Progress */}
                {isBuilding && (
                  <div className="space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="text-white">Building ISO...</span>
                      <span className="text-gray-400">{Math.round(buildProgress)}%</span>
                    </div>
                    <Progress value={buildProgress} className="bg-slate-700" />
                  </div>
                )}

                {/* Build Button */}
                <Button 
                  onClick={startBuild}
                  disabled={isBuilding}
                  className="w-full bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 text-white font-semibold py-3 text-lg"
                >
                  <HardDrive className="h-5 w-5 mr-2" />
                  {isBuilding ? 'Building ISO...' : 'Build Custom ISO'}
                </Button>

                {/* Previous Builds */}
                <div className="mt-8">
                  <h4 className="text-white font-semibold mb-4">Your ISO Builds</h4>
                  <div className="space-y-3">
                    {isoConfigs.map((config) => (
                      <div key={config.id} className="flex items-center justify-between p-4 bg-slate-700 rounded-lg">
                        <div className="flex items-center space-x-3">
                          {getStatusIcon(config.status)}
                          <div>
                            <h5 className="text-white font-medium">{config.name}</h5>
                            <p className="text-sm text-gray-400">
                              {new Date(config.createdAt).toLocaleDateString()} • {config.size || 'Building...'}
                            </p>
                          </div>
                        </div>
                        {config.status === 'completed' && (
                          <Button variant="outline" size="sm" className="border-slate-600 text-white hover:bg-slate-600">
                            <Download className="h-4 w-4 mr-2" />
                            Download
                          </Button>
                        )}
                        {config.status === 'building' && config.progress && (
                          <div className="flex items-center space-x-2">
                            <Progress value={config.progress} className="w-24 bg-slate-600" />
                            <span className="text-sm text-gray-400">{config.progress}%</span>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
};

export default ArchISOBuilder;