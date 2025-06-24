import axios from 'axios';

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

// API service for Arch ISO Builder
export const archISOAPI = {
  // Get available profiles
  getProfiles: async () => {
    try {
      const response = await axios.get(`${API}/profiles`);
      return response.data;
    } catch (error) {
      console.error('Error fetching profiles:', error);
      throw error;
    }
  },

  // Get package categories
  getPackageCategories: async () => {
    try {
      const response = await axios.get(`${API}/packages`);
      return response.data;
    } catch (error) {
      console.error('Error fetching packages:', error);
      throw error;
    }
  },

  // Get desktop environments
  getDesktopEnvironments: async () => {
    try {
      const response = await axios.get(`${API}/desktop-environments`);
      return response.data;
    } catch (error) {
      console.error('Error fetching desktop environments:', error);
      throw error;
    }
  },

  // Create ISO configuration
  createISOConfig: async (configData) => {
    try {
      const response = await axios.post(`${API}/iso-configs`, configData);
      return response.data;
    } catch (error) {
      console.error('Error creating ISO config:', error);
      throw error;
    }
  },

  // Get all ISO configurations
  getISOConfigs: async () => {
    try {
      const response = await axios.get(`${API}/iso-configs`);
      return response.data;
    } catch (error) {
      console.error('Error fetching ISO configs:', error);
      throw error;
    }
  },

  // Get specific ISO configuration
  getISOConfig: async (configId) => {
    try {
      const response = await axios.get(`${API}/iso-configs/${configId}`);
      return response.data;
    } catch (error) {
      console.error('Error fetching ISO config:', error);
      throw error;
    }
  },

  // Delete ISO configuration
  deleteISOConfig: async (configId) => {
    try {
      const response = await axios.delete(`${API}/iso-configs/${configId}`);
      return response.data;
    } catch (error) {
      console.error('Error deleting ISO config:', error);
      throw error;
    }
  },

  // Get build logs
  getBuildLogs: async (configId) => {
    try {
      const response = await axios.get(`${API}/iso-configs/${configId}/logs`);
      return response.data;
    } catch (error) {
      console.error('Error fetching build logs:', error);
      throw error;
    }
  },

  // Download ISO
  downloadISO: async (filename) => {
    try {
      const response = await axios.get(`${API}/downloads/${filename}`, {
        responseType: 'blob'
      });
      return response.data;
    } catch (error) {
      console.error('Error downloading ISO:', error);
      throw error;
    }
  }
};

export default archISOAPI;