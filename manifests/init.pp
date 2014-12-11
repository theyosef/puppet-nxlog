class nxlog (
    $package_ensure             =   present,
    $package_name               =   "NXLOG-CE",
    $package_version            =   "2.8.1248",
    $install_dir                =   "C:\\Program Files (x86)\\nxlog\\",
    $package_src                =   "http://artifactory.ds.adp.com/artifactory/binary-local/nxLog/nxlog-ce-2.8.1248.msi",
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
    $local_package_msi = "${temp_media_dir}${package_name}-${package_version}.msi"

    if "${operatingsystem}" == 'windows' {

        if $package_ensure == 'installed' or $package_ensure == 'present' {
            service { $service_name:
                ensure  => $service_ensure,
                require => Package[$package_name],
            }        
        }

        file { "${temp_media_dir}" :
            ensure => 'directory',
            recurse => true,
        } ->

        file { "${local_package_msi}" :
            ensure => 'file',
            source => "${package_src}",
        }

  
            
        package { $package_name:
            ensure  => $package_ensure,
            source  => $local_package_msi,
        }
        
        file { "${config_dir}${config_file}":
            ensure  => present,
            content => regsubst(template('nxlog/nxlog.conf.erb'), '\n', "\r\n", 'EMG'),
            notify  => Service[$service_name],
            require => Package[$package_name],
        }   
    }
    else{
        notify { 'The module is only supported on windows - no action taken.':  
        }
    }


    #create_resources(nxlog::conf,hiera('nxlog::conf::inputs'))
}