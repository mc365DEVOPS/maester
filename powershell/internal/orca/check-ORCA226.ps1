# Generated on 10/25/2024 17:00:43 by .\build\orca\Update-OrcaTests.ps1

<#

226 - Check Safe Links Policy Exists for all domains

#>

using module "..\Maester.psm1"

class ORCA226 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA226()
    {
        $this.Control=226
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Safe Links Policy Rules"
        $this.PassText="Each domain has a Safe Link policy applied to it"
        $this.FailRecommendation="Apply a Safe Links policy to every domain"
        $this.Importance="Microsoft Defender for Office 365 Safe Links policies are applied using rules. The recipient domain condition is the most effective way of applying the Safe Links policy, ensuring no users are left without protection. If polices are applied using group membership make sure you cover all users through this method. Applying polices this way can be challenging, users may left unprotected if group memberships are not accurate and up to date. It is important not to rely on the 'built-in' Safe Links policy, as this policy only applies the minimum level of protections and should serve as a catch-all."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Domain"
        $this.ItemName="Policy"
        $this.DataType="Priority"
        $this.ChiValue=[ORCACHI]::High
        $this.Links= @{
            "Microsoft 365 Defender Portal - Safe links"="https://security.microsoft.com/safelinksv2"
            "Order and precedence of email protection"="https://aka.ms/orca-atpp-docs-4"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        ForEach($AcceptedDomain in $Config["AcceptedDomains"]) 
        {

            # Set up the config object

            $Rules = @()

            # Go through each Safe Links Policy

            ForEach($Rule in ($Config["SafeLinksRules"] | Sort-Object Priority)) 
            {
                if($Rule.State -eq "Enabled")
                {
                    if($Rule.RecipientDomainIs -contains $AcceptedDomain.Name -and ($Rule.ExceptIfRecipientDomainIs -notcontains $AcceptedDomain.Name) -and ($null -eq $Rule.ExceptIfSentToMemberOf ) -and ($null -eq $Rule.ExceptIfSentTo) )
                    {
                        # Policy applies to this domain

                        $Rules += New-Object -TypeName PSObject -Property @{
                            PolicyName=$($Rule.SafeLinksPolicy)
                            Priority=$($Rule.Priority)
                        }

                    }
                }
            }
            ForEach($Rule in ($Config["ATPProtectionPolicyRule"] | Sort-Object Priority)) 
            {
                if(($Rule.SafeLinksPolicy -ne "") -and ($null -ne $Rule.SafeLinksPolicy ))
                { 
                   if($Rule.State -eq "Enabled")
                   {
                        if($Rule.RecipientDomainIs -contains $AcceptedDomain.Name -and ($Rule.ExceptIfRecipientDomainIs -notcontains $AcceptedDomain.Name) -and ($null -eq $Rule.ExceptIfSentToMemberOf ) -and ($null -eq $Rule.ExceptIfSentTo) )
                        {
                            # Policy applies to this domain

                            $Rules += New-Object -TypeName PSObject -Property @{
                            PolicyName=$($Rule.SafeLinksPolicy)
                            Priority=$($Rule.Priority)
                            }

                        }   
                    }
                }
            }
            If($Rules.Count -gt 0)
            {
                $Count = 0
                $CountOfPolicies = ($Rules).Count

                ForEach($r in ($Rules | Sort-Object Priority))
                {
                    $IsBuiltIn = $false
                    $policyname = $($r.PolicyName)
                    $priority =$($r.Priority)
                    if($policyname -match "Built-In" -and $CountOfPolicies -gt 1)
                    {
                        $IsBuiltIn =$True
                        $policyname = "$policyname" +" [Built-In]"
                    }
                    elseif(($policyname -eq "Default" -or $policyname -eq "Office365 AntiPhish Default") -and $CountOfPolicies -gt 1)
                    {
                        $IsBuiltIn =$True
                        $policyname = "$policyname" +" [Default]"
                    }

                    $Count++

                    $ConfigObject = [ORCACheckConfig]::new()

                    $ConfigObject.Object=$($AcceptedDomain.Name)
                    $ConfigObject.ConfigItem=$policyname
                    $ConfigObject.ConfigData=$priority

                    If($Count -eq 1)
                    {
                        # First policy based on priority is a pass
                        if($IsBuiltIn)
                        {
                            $ConfigObject.InfoText = "This is a Built-In/Default policy managed by Microsoft and therefore cannot be edited. Other policies are set up in this area. It is being flagged only for informational purpose."
                            $ConfigObject.SetResult([ORCAConfigLevel]::Informational,"Fail")
                        }
                        else
                        {
                            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
                        }
                    }
                    else
                    {
                        if($IsBuiltIn)
                        {
                            $ConfigObject.InfoText = "This is a Built-In/Default policy managed by Microsoft and therefore cannot be edited. Other policies are set up in this area. It is being flagged only for informational purpose."
                            $ConfigObject.SetResult([ORCAConfigLevel]::Informational,"Fail")
                        }
                        else
                        {
                        # Additional policies based on the priority should be listed as informational
                            $ConfigObject.InfoText = "There are multiple policies that apply to this domain, only the policy with the lowest priority will apply. This policy may not apply based on a lower priority."
                            $ConfigObject.SetResult([ORCAConfigLevel]::Informational,"Fail")
                        }
                    }    

                    $this.AddConfig($ConfigObject)
                }
            } 
            elseif($Rules.Count -eq 0)
            {
                # No policy is applying to this domain

                $ConfigObject = [ORCACheckConfig]::new()

                $ConfigObject.Object=$($AcceptedDomain.Name)
                $ConfigObject.ConfigItem="No Policy Applying"
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")            
    
                $this.AddConfig($ConfigObject)     
            }

        }

    }

}
