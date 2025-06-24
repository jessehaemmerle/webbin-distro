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
import { Download, Settings, Package, Users, Monitor, Play, CheckCircle, Clock, AlertCircle, Search, Filter, X, Loader2, RefreshCw } from 'lucide-react';
import { useToast } from '../hooks/use-toast';
import { archISOAPI } from '../services/api';

const ArchISOBuilder = () => {
  const [currentTab, setCurrentTab] = useState('profiles');
  const [selectedProfile, setSelectedProfile] = useState(null);
  const [profiles, setProfiles] = useState([]);
  const [packageCategories, setPackageCategories] = useState([]);
  const [desktopEnvironments, setDesktopEnvironments] = useState([]);
  const [userConfig, setUserConfig] = useState({
    hostname: 'archbox',
    username: 'user',
    timezone: 'UTC',
    locale: 'en_US.UTF-8',
    keymap: 'us'
  });
  const [isoConfigs, setISOConfigs] = useState([]);
  const [packageSearch, setPackageSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [isLoading, setIsLoading] = useState(true);
  const [isBuilding, setIsBuilding] = useState(false);
  const { toast } = useToast();

  // Load initial data
  useEffect(() => {
    loadInitialData();
    // Set up polling for ISO configs
    const interval = setInterval(loadISOConfigs, 3000);
    return () => clearInterval(interval);
  }, []);

  const loadInitialData = async () => {
    try {
      setIsLoading(true);
      const [profilesData, packagesData, desktopData, configsData] = await Promise.all([
        archISOAPI.getProfiles(),
        archISOAPI.getPackageCategories(),
        archISOAPI.getDesktopEnvironments(),
        archISOAPI.getISOConfigs()
      ]);

      setProfiles(profilesData);
      setPackageCategories(packagesData);
      setDesktopEnvironments(desktopData);
      setISOConfigs(configsData);
    } catch (error) {
      toast({
        title: "Error Loading Data",
        description: "Failed to load initial data. Please refresh the page.",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const loadISOConfigs = async () => {
    try {
      const configsData = await archISOAPI.getISOConfigs();
      setISOConfigs(configsData);
    } catch (error) {
      console.error('Error refreshing ISO configs:', error);
    }
  };

  const selectProfile = (profile) => {
    setSelectedProfile(profile);
    
    if (profile.id === 'custom') {
      // For custom profile, only select required packages
      const updatedCategories = packageCategories.map(category => ({
        ...category,
        packages: category.packages.map(pkg => ({
          ...pkg,
          selected: pkg.required || false
        }))
      }));
      setPackageCategories(updatedCategories);
      
      toast({
        title: "Custom Profile Selected",
        description: "Start with essential packages only. Add more packages as needed.",
      });
    } else {
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
    }
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

  const getFilteredPackages = () => {
    return packageCategories.map(category => {
      if (selectedCategory !== 'all' && category.id !== selectedCategory) {
        return { ...category, packages: [] };
      }
      
      const filteredPackages = category.packages.filter(pkg =>
        pkg.name.toLowerCase().includes(packageSearch.toLowerCase()) ||
        pkg.description.toLowerCase().includes(packageSearch.toLowerCase())
      );
      
      return { ...category, packages: filteredPackages };
    }).filter(category => category.packages.length > 0);
  };

  const clearFilters = () => {
    setPackageSearch('');
    setSelectedCategory('all');
  };

  const startBuild = async () => {
    if (!selectedProfile) {
      toast({
        title: "No Profile Selected",
        description: "Please select a profile before building.",
        variant: "destructive"
      });
      return;
    }

    const selectedDE = desktopEnvironments.find(de => de.selected);
    const configData = {
      name: `${selectedProfile.name} - ${new Date().toLocaleDateString()}`,
      profile_id: selectedProfile.id,
      selected_packages: getSelectedPackages(),
      desktop_environment: selectedDE?.id || 'none',
      user_config: userConfig,
      custom_settings: {}
    };

    try {
      setIsBuilding(true);
      const newConfig = await archISOAPI.createISOConfig(configData);
      
      toast({
        title: "Build Started",
        description: "Your ISO build has been queued and will start shortly.",
      });

      // Add to local state immediately
      setISOConfigs(prev => [newConfig, ...prev]);
      
      // Switch to build tab to show progress
      setCurrentTab('build');
      
    } catch (error) {
      toast({
        title: "Build Failed",
        description: "Failed to start ISO build. Please try again.",
        variant: "destructive"
      });
    } finally {
      setIsBuilding(false);
    }
  };

  const handleDownload = async (config) => {
    if (!config.download_url) return;
    
    try {
      const filename = config.download_url.split('/').pop();
      window.open(`${process.env.REACT_APP_BACKEND_URL}/api/downloads/${filename}`, '_blank');
      
      toast({
        title: "Download Started",
        description: "Your ISO download has started.",
      });
    } catch (error) {
      toast({
        title: "Download Failed",
        description: "Failed to download ISO file.",
        variant: "destructive"
      });
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'completed': return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'building': return <Clock className="h-4 w-4 text-blue-500" />;
      case 'failed': return <AlertCircle className="h-4 w-4 text-red-500" />;
      default: return <Clock className="h-4 w-4 text-gray-500" />;
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="h-12 w-12 animate-spin text-purple-400 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-white mb-2">Loading Arch ISO Builder</h2>
          <p className="text-gray-400">Setting up your build environment...</p>
        </div>
      </div>
    );
  }

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
                  Start with a pre-configured profile or create a completely custom configuration
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {profiles.map((profile) => (
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
                          {profile.id === 'custom' ? 'Full Control' : `${profile.packages.length} packages`}
                        </Badge>
                        {profile.id === 'custom' && (
                          <div className="mt-3">
                            <Badge variant="outline" className="border-purple-500 text-purple-400">
                              Recommended for Advanced Users
                            </Badge>
                          </div>
                        )}
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Enhanced Packages Tab */}
          <TabsContent value="packages" className="space-y-6">
            <Card className="bg-slate-800 border-slate-700">
              <CardHeader>
                <CardTitle className="text-white">Package Selection</CardTitle>
                <CardDescription>
                  Choose packages to include in your ISO. Required packages cannot be deselected.
                </CardDescription>
              </CardHeader>
              <CardContent>
                {/* Search and Filter Controls */}
                <div className="flex flex-col md:flex-row gap-4 mb-6">
                  <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                      placeholder="Search packages..."
                      value={packageSearch}
                      onChange={(e) => setPackageSearch(e.target.value)}
                      className="pl-10 bg-slate-700 border-slate-600 text-white"
                    />
                  </div>
                  <div className="flex gap-2">
                    <Select value={selectedCategory} onValueChange={setSelectedCategory}>
                      <SelectTrigger className="w-48 bg-slate-700 border-slate-600 text-white">
                        <Filter className="h-4 w-4 mr-2" />
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent className="bg-slate-700 border-slate-600">
                        <SelectItem value="all">All Categories</SelectItem>
                        {packageCategories.map(category => (
                          <SelectItem key={category.id} value={category.id}>
                            {category.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {(packageSearch || selectedCategory !== 'all') && (
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={clearFilters}
                        className="border-slate-600 text-white hover:bg-slate-600"
                      >
                        <X className="h-4 w-4 mr-2" />
                        Clear
                      </Button>
                    )}
                  </div>
                </div>

                {/* Package Count Summary */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                  <div className="bg-slate-700 p-4 rounded-lg text-center">
                    <div className="text-2xl font-bold text-white">{getSelectedPackages().length}</div>
                    <div className="text-sm text-gray-400">Selected Packages</div>
                  </div>
                  <div className="bg-slate-700 p-4 rounded-lg text-center">
                    <div className="text-2xl font-bold text-white">
                      {packageCategories.flatMap(c => c.packages?.filter(p => p.required) || []).length}
                    </div>
                    <div className="text-sm text-gray-400">Required Packages</div>
                  </div>
                  <div className="bg-slate-700 p-4 rounded-lg text-center">
                    <div className="text-2xl font-bold text-white">
                      {packageCategories.flatMap(c => c.packages || []).length}
                    </div>
                    <div className="text-sm text-gray-400">Total Available</div>
                  </div>
                </div>

                <ScrollArea className="h-96">
                  {getFilteredPackages().map((category) => (
                    <div key={category.id} className="mb-6">
                      <div className="flex items-center justify-between mb-3">
                        <h3 className="text-lg font-semibold text-white">{category.name}</h3>
                        <Badge variant="secondary" className="bg-slate-600">
                          {category.packages?.filter(p => p.selected).length || 0}/{category.packages?.length || 0} selected
                        </Badge>
                      </div>
                      <p className="text-sm text-gray-400 mb-3">{category.description}</p>
                      <div className="space-y-2">
                        {(category.packages || []).map((pkg) => (
                          <div key={pkg.name} className="flex items-center space-x-3 p-3 rounded-lg bg-slate-700 hover:bg-slate-600 transition-colors">
                            <Checkbox
                              checked={pkg.selected}
                              disabled={pkg.required}
                              onCheckedChange={() => togglePackage(category.id, pkg.name)}
                              className="data-[state=checked]:bg-purple-600"
                            />
                            <div className="flex-1">
                              <div className="flex items-center gap-2 mb-1">
                                <span className="text-white font-medium">{pkg.name}</span>
                                {pkg.required && <Badge variant="destructive" className="text-xs">Required</Badge>}
                                {pkg.selected && !pkg.required && <Badge variant="default" className="text-xs bg-purple-600">Selected</Badge>}
                              </div>
                              <p className="text-sm text-gray-400">{pkg.description}</p>
                            </div>
                          </div>
                        ))}
                      </div>
                      <Separator className="mt-4 bg-slate-600" />
                    </div>
                  ))}
                  {getFilteredPackages().length === 0 && (
                    <div className="text-center py-8">
                      <p className="text-gray-400">No packages found matching your search criteria.</p>
                    </div>
                  )}
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
                <div className="flex items-center justify-between">
                  <div>
                    <CardTitle className="text-white">Build Configuration</CardTitle>
                    <CardDescription>
                      Review your configuration and build your custom Arch ISO
                    </CardDescription>
                  </div>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={loadISOConfigs}
                    className="border-slate-600 text-white hover:bg-slate-600"
                  >
                    <RefreshCw className="h-4 w-4 mr-2" />
                    Refresh
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Configuration Summary */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="bg-slate-700 p-4 rounded-lg">
                    <h4 className="text-white font-semibold mb-2">Profile</h4>
                    <p className="text-gray-300">{selectedProfile?.name || 'No Profile Selected'}</p>
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

                {/* Build Button */}
                <Button 
                  onClick={startBuild}
                  disabled={isBuilding || !selectedProfile}
                  className="w-full bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 text-white font-semibold py-3 text-lg disabled:opacity-50"
                >
                  {isBuilding ? (
                    <>
                      <Loader2 className="h-5 w-5 mr-2 animate-spin" />
                      Starting Build...
                    </>
                  ) : (
                    <>
                      <Play className="h-5 w-5 mr-2" />
                      Build Custom ISO
                    </>
                  )}
                </Button>

                {!selectedProfile && (
                  <p className="text-center text-gray-400 text-sm">
                    Please select a profile from the Profiles tab to continue.
                  </p>
                )}

                {/* ISO Builds */}
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
                              {new Date(config.created_at).toLocaleDateString()} • {config.size || 'Building...'}
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          {config.status === 'building' && (
                            <div className="flex items-center space-x-2">
                              <Progress value={config.progress} className="w-24 bg-slate-600" />
                              <span className="text-sm text-gray-400">{config.progress}%</span>
                            </div>
                          )}
                          {config.status === 'completed' && (
                            <Button 
                              variant="outline" 
                              size="sm" 
                              onClick={() => handleDownload(config)}
                              className="border-slate-600 text-white hover:bg-slate-600"
                            >
                              <Download className="h-4 w-4 mr-2" />
                              Download
                            </Button>
                          )}
                        </div>
                      </div>
                    ))}
                    {isoConfigs.length === 0 && (
                      <div className="text-center py-8">
                        <p className="text-gray-400">No ISO builds yet. Create your first build above!</p>
                      </div>
                    )}
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