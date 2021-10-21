configuration ServerConfiguration {

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    node ("VM1","VM2")
    {
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
        }

        File DSCFolder {
            DestinationPath = "C:\ProgramData\DSC"
            Ensure = "Present"
            Type = "Directory"
        }

        xRemoteFile DownloadSampleWebApp
        {
            DestinationPath = "C:\ProgramData\DSC"
            Uri = "https://github.com/waynehoggett/AzureHackathons/raw/main/1%20-%20Infrastructure%20as%20Code%20with%20Azure%20Bicep%20and%20PowerShell%20DSC/Challenges/2.3/SampleWebApp.zip"
            DependsOn = "[File]DSCFolder"
        }

        Archive UnzipSampleWebApp
        {
            Path = "C:\ProgramData\DSC\SampleWebApp.zip"
            Destination = "C:\inetpub\wwwroot"
            Force = $true
            DependsOn = "[xRemoteFile]DownloadSampleWebApp"
        }
    }
}