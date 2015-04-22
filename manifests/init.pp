class nxlog (
    $package_ensure             =   present,
    $package_name               =   "NXLOG-CE",
    $package_version            =   "2.8.1248",
    $install_dir                =   "C:\\Program Files (x86)\\nxlog\\",
    $package_src                =   "\\path\\to\\nxlog-ce-2.8.1248.msi", # unc
    $package_src_http           =   undef, # if defined, HTTP, ftp, local, s3
    $service_name               =   "nxlog",
    $service_ensure             =   running,
    $config_dir                 =   "C:\\Program Files (x86)\\nxlog\\conf\\",
    $config_file                =   "nxlog.conf",
    $temp_media_dir             =   "C:\\Media\\",
    $include_external_configs   =   false,
    $external_config_path       =   "C:\\nxlog\\configuration\\*.nxlog.conf",
    $nxlog_moduledir            =   "C:\\Program Files (x86)\\nxlog\\modules",
    $nxlog_cachedir             =   "C:\\Program Files (x86)\\nxlog\\data",                
    $nxlog_pidfile              =   "C:\\Program Files (x86)\\nxlog\\data\\nxlog.pid",
    $nxlog_spooldir             =   "C:\\Program Files (x86)\\nxlog\\data",
    $nxlog_logfile              =   "C:\\Program Files (x86)\\nxlog\\data\\nxlog.log",
)
{
  include staging


    $local_package_msi = "${temp_media_dir}${package_name}-${package_version}.msi"

    if "${::operatingsystem}" == 'windows' {

        Exec {
            path => "${::path}",
        }

        if $package_ensure == 'installed' or $package_ensure == 'present' {

            
            
            package { $package_name:
                ensure  => $package_ensure,
                source  => $local_package_msi,
                require => File["${local_package_msi}"],
            }
            
            file { "${config_dir}${config_file}":
                ensure  => present,
                content => regsubst(template('nxlog/nxlog.conf.erb'), '\n', "\r\n", 'EMG'),
                require => Package["${package_name}"],
            } 
            
            service { $service_name:
                ensure  => $service_ensure,
                require => File["${config_dir}${config_file}"],
            }
            
            if ! defined(File[$temp_media_dir]) {
                file { $temp_media_dir:
                    ensure=>directory,
                }
            }     




            if $package_src_http == undef {
               file { "${local_package_msi}" :
                    ensure => 'file',
                    source => "${package_src}",
                    replace => false,
                    require => File[$temp_media_dir],
               }
            }
            else{
                staging::file { "${package_name}-${package_version}.msi":
                    source  => "${package_src_http}",
                }
                ->
                file { "${local_package_msi}":
                  ensure => 'file',
                  source => "${staging::path}/nxlog/${package_name}-${package_version}.msi",
                  replace => false,
                  require => File[$temp_media_dir],
                }
            }

            


        } # if $package_ensure == 'installed' or $package_ensure == 'present' 
    }# if "${::operatingsystem}" == 'windows'
    else{
        notice("NXLOG: Not supported on non-windows platforms at this time.")
    }# else of (if "${::operatingsystem}" == 'windows') 
      

}