#retrieve all web apps from subscription
$webApps = Get-AzWebApp

# create an array of pscustomobject to store the results
$myitems = @() 

#loop through each web app, list all the slots and retrieve the app settings
foreach ($webApp in $webApps) {

    #reload all data from web app
    $webApp = Get-AzWebApp -ResourceGroupName $webApp.ResourceGroup -Name $webApp.Name

    # if $webApp.Kind equals to "app" then it is a web app, otherwise it is a function app
    if ($webApp.Kind -eq "app") {

        $HealthCheckPath = $webApp.SiteConfig.HealthCheckPath
        $ExpectedHealthCheckPath = "/healthCheck" 
        # if $HealthCheckPath is not equal to "ExpectedHealthCheckPath" then add an item to $myitems array
        if (!$ExpectedHealthCheckPath.Equals($HealthCheckPath)) {
            $myitems += [pscustomobject]@{PolicyDefinitionName="Wrong HealthCheckPath";ResourceGroup=$webApp.ResourceGroup;ResourceId=$webApp.Name;Comment="HealthCheckPath should be $ExpectedHealthCheckPath"}
        }

        $appSettings = $webApp.SiteConfig.AppSettings
        $myVar = $appSettings | Where-Object { $_.Name -like "WEBSITE_LOCAL_CACHE_OPTION" }    
        
        #  if $myVar does not exists or has a value different than "Always"
        # add an item to $myitems array
        if (!$myVar -or $myVar.value -ne "Always") {
            $myitems += [pscustomobject]@{PolicyDefinitionName="Wrong WEBSITE_LOCAL_CACHE_OPTION";ResourceGroup=$webApp.ResourceGroup;ResourceId=$webApp.Name;Comment="Production slot should have WEBSITE_LOCAL_CACHE_OPTION=Always"}
        }

        # get in mySiteBindingAppSetting the app setting WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG
        # if mySiteBindingAppSetting value is not equal to 1 then add an item to $myitems array
        $mySiteBindingAppSetting = $appSettings | Where-Object { $_.Name -like "WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG" }
        if ($mySiteBindingAppSetting.value -ne "1") {
            $myitems += [pscustomobject]@{PolicyDefinitionName="Wrong WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG";ResourceGroup=$webApp.ResourceGroup;ResourceId=$webApp.Name;Comment="Production slot should have WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG=1"}
        }

        $slots = Get-AzWebAppSlot -ResourceGroupName $webApp.ResourceGroup -Name $webApp.Name
        foreach ($slot in $slots) {
           
            #reload all data from slot
            # Parse slot.Name to get only the slot name, currently slot.Name has this format <app>/<slotName>.
            # after the parsing it should return only the <slotName>
            $slotName = $slot.Name.Split("/")[1]

            $slot = Get-AzWebAppSlot -ResourceGroupName $slot.ResourceGroup -Name $webApp.Name -Slot $slotName

            $appSettings = $slot.SiteConfig.AppSettings
            
            $myVar = $appSettings | Where-Object { $_.Name -like "WEBSITE_LOCAL_CACHE_OPTION" }  
            
            # ir myVar has a value of Always then add an item to $myitems array
            if ($myVar.value -eq "Always") {
                $myitems += [pscustomobject]@{PolicyDefinitionName="Wrong WEBSITE_LOCAL_CACHE_OPTION";ResourceGroup=$slot.ResourceGroup;ResourceId=$slot.Name;Comment="Slot $slotName should not have WEBSITE_LOCAL_CACHE_OPTION=Always"}
            }

            # get in mySiteBindingAppSetting the app setting WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG
            # if mySiteBindingAppSetting value is not equal to 1 then add an item to $myitems array
            $mySiteBindingAppSetting = $appSettings | Where-Object { $_.Name -like "WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG" }
            if ($mySiteBindingAppSetting.value -ne "1") {
                $myitems += [pscustomobject]@{PolicyDefinitionName="Wrong WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG";ResourceGroup=$webApp.ResourceGroup;ResourceId=$webApp.Name;Comment="Production slot should have WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG=1"}
            }

        }

    }
}

return $myitems