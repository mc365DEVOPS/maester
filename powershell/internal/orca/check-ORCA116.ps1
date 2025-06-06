# Generated on 04/16/2025 21:38:23 by .\build\orca\Update-OrcaTests.ps1

using module ".\orcaClass.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSPossibleIncorrectComparisonWithNull', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()


<#

116 - Check MDO Phishing Mailbox Intelligence Protection action is set Move to Junk for recommended and Quarantine for strict 

#>



class ORCA116 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA116()
    {
        $this.Control=116
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Mailbox Intelligence Protection Action"
        $this.PassText="Mailbox intelligence based impersonation protection action set to move message to junk mail folder"
        $this.FailRecommendation="Change Mailbox intelligence based impersonation protection action to move message to junk mail folder"
        $this.Importance="Mailbox intelligence protection enhances impersonation protection for users based on each user's individual sender graph. Move messages that are caught to junk mail folder."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Antiphishing Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::Low
        $this.Links=@{
            "Microsoft 365 Defender Portal - Anti-phishing"="https://security.microsoft.com/antiphishing"
            "Set up Microsoft Defender for Office 365 anti-phishing and anti-phishing policies"="https://aka.ms/orca-atpp-docs-9"
            "Recommended settings for EOP and Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-7"
        }   
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        <#
        
        This check does not need a default catch all as the default anti-phishing policy cannot be disabled
        
        #>
       
        ForEach($Policy in ($Config["AntiPhishPolicy"] ))
        {

            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $MailboxIntelligenceProtectionAction = $($Policy.MailboxIntelligenceProtectionAction)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            # Determine if Mailbox Intelligence Protection action is configured

            $ConfigObject = [ORCACheckConfig]::new()

            $ConfigObject.Object=$policyname
            $ConfigObject.ConfigItem="MailboxIntelligenceProtectionAction"
            $ConfigObject.ConfigData=$MailboxIntelligenceProtectionAction
            $ConfigObject.ConfigDisabled = $Config["PolicyStates"][$Policy.Guid.ToString()].Disabled
            $ConfigObject.ConfigWontApply = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $ConfigObject.ConfigReadonly=$Policy.IsPreset
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()
            
            # For standard, this should be MoveToJmf
            If($MailboxIntelligenceProtectionAction -ne "MoveToJmf")
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,[ORCAResult]::Fail)       
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,[ORCAResult]::Pass)               
            }

            # For strict, this should be Quarantine
            If($MailboxIntelligenceProtectionAction -ne "Quarantine")
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,[ORCAResult]::Fail)        
            }
            Else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Strict,[ORCAResult]::Pass)                         
            }

            # For either Delete or Quarantine we should raise an informational
            If($MailboxIntelligenceProtectionAction -eq "Delete" -or $MailboxIntelligenceProtectionAction -eq "Quarantine")
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::All,[ORCAResult]::Informational)
                $ConfigObject.InfoText = "The $($MailboxIntelligenceProtectionAction) option may impact the users ability to release emails and may impact user experience."
            }

            $this.AddConfig($ConfigObject)

        }

        If($Config["AnyPolicyState"][[PolicyType]::Antiphish] -eq $False)
        {
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object="No Enabled Policies"
            $ConfigObject.ConfigItem="MailboxIntelligenceProtectionAction"
            $ConfigObject.ConfigData=""
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,[ORCAResult]::Fail)
            $this.AddConfig($ConfigObject)
        }


    }

}
