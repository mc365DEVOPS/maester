# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()




class ORCA120_phish : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA120_phish()
    {
        $this.Control="120-phish"
        $this.Area="Zero Hour Autopurge"
        $this.Name="Zero Hour Autopurge Enabled for Phish"
        $this.PassText="Zero Hour Autopurge is Enabled"
        $this.FailRecommendation="Enable Zero Hour Autopurge"
        $this.Importance="Zero Hour Autopurge can assist removing false-negatives post detection from mailboxes. By default, it is enabled."
        $this.ExpandResults=$True
        $this.ItemName="Policy"
        $this.DataType="ZapEnabled Setting"
        $this.ChiValue=[ORCACHI]::VeryHigh
        $this.Links= @{
            "Microsoft 365 Defender Portal - Anti-spam settings"="https://security.microsoft.com/antispam"
            "Zero-hour auto purge - protection against spam and malware"="https://aka.ms/orca-zha-docs-2"
            "Recommended settings for EOP and Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-6"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
        #$CountOfPolicies = ($Config["HostedContentFilterPolicy"]).Count
        $CountOfPolicies = ($global:HostedContentPolicyStatus| Where-Object {$_.IsEnabled -eq $True}).Count
       
        ForEach($Policy in $Config["HostedContentFilterPolicy"]) 
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $PhishZapEnabled = $($Policy.PhishZapEnabled)
            
            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.ConfigItem=$policyname
            $ConfigObject.ConfigData=$PhishZapEnabled
            $ConfigObject.ConfigReadonly=$Policy.IsPreset
            $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
            $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            if($PhishZapEnabled -eq $true) 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            } 
            else
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            # Add config to check
            $this.AddConfig($ConfigObject)

        }        

    }

}
