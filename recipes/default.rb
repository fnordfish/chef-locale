#
# Cookbook Name:: locale
# Recipe:: default
#
# Copyright 2011, Heavy Water Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if platform?("ubuntu", "debian")

  package "locales" do
    action :install
  end

  execute "Install missing locale" do
    not_if "grep -q #{node[:locale][:lang]} /var/lib/locales/supported.d/*"
    command "locale-gen #{node[:locale][:lang]}"
  end

  execute "Update locale" do
    not_if "cat /etc/default/locale | grep -qx LANG=#{node[:locale][:lang]}"
    lang_settings = ["LANG=#{node[:locale][:lang]}"]
    lang_settings << "LANGUAGE=#{node[:locale][:language]}" unless node[:locale][:language].nil?
    node[:locale].select { |k,v| k =~ /lc_.*/ }.each { |k, v|
      lang_settings << "#{k.upcase}=#{v}" unless v.nil?
    }

    command_string = "update-locale --reset #{lang_settings.join(' ')}"
    Chef::Log.debug("locale command is #{command_string.inspect}")
    command command_string
  end

end

if platform?("redhat", "centos", "fedora")

  execute "Update locale" do
    command "locale -a | grep -qx #{node[:locale][:lang]} && sed -i 's|LANG=.*|LANG=#{node[:locale][:lang]}|' /etc/sysconfig/i18n"
    not_if "grep -qx LANG=#{node[:locale][:lang]} /etc/sysconfig/i18n"
  end

end

