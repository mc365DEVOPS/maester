# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()




class ORCA112 : ORCACheck
{
    <#
    
        Check if the Anti-spoofing policy action is configured to Move message to the recipients' Junk Email folder as per Standard security settings for Office 365 EOP/MDO
    
    #>

    ORCA112()
    {
        $this.Control="ORCA-112"
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Anti-spoofing protection action"
        $this.PassText="Anti-spoofing protection action is configured to Move message to the recipients' Junk Email folders in Anti-phishing policy"
        $this.FailRecommendation="Configure Anti-spoofing protection action to Move message to the recipients' Junk Email folders in Anti-phishing policy"
        $this.Importance="When the sender email address is spoofed, the message appears to originate from someone or somewhere other than the actual source. With Standard security settings it is recommended to configure Anti-spoofing protection action to Move message to the recipients' Junk Email folders in Office 365 Anti-phishing policies."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Antiphishing Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::Medium
        $this.Links= @{
            "Microsoft 365 Defender Portal - Anti-phishing"="https://security.microsoft.com/antiphishing"
            "Configuring the anti-spoofing policy"="https://aka.ms/orca-atpp-docs-5"
            "Recommended settings for EOP and Office 365 Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-6"
        }
    
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {
       
        ForEach ($Policy in $Config["AntiPhishPolicy"])
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $AuthenticationFailAction = $($Policy.AuthenticationFailAction)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name
            $identity = $($Policy.Identity)
            $enabled = $($Policy.Enabled)
            
            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object=$policyname
            $ConfigObject.ConfigItem="AuthenticationFailAction"
            $ConfigObject.ConfigData=$AuthenticationFailAction
            $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
            $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $ConfigObject.ConfigReadonly=$Policy.IsPreset
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            If(($enabled -eq $true -and $AuthenticationFailAction -eq "MoveToJmf") -or ($identity -eq "Office365 AntiPhish Default" -and $AuthenticationFailAction -eq "MoveToJmf"))
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            If(($enabled -eq $true -and $AuthenticationFailAction -eq "Quarantine") -or ($identity -eq "Office365 AntiPhish Default" -and $AuthenticationFailAction -eq "Quarantine"))
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,"Pass")
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,"Fail")
            }
            
            # Add config to check
            $this.AddConfig($ConfigObject)

        }
        
    
        If($Config["AnyPolicyState"][[PolicyType]::Antiphish] -eq $False)
        {
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object="No Enabled Policies"
            $ConfigObject.ConfigItem="AuthenticationFailAction"
            $ConfigObject.ConfigData=""
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            $this.AddConfig($ConfigObject)
        }
        

    }

}
