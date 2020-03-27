# https://www.powershellgallery.com/packages/newtonsoft.json/1.0.1.2
function ConvertFrom-JObject($obj) {
   if ($obj -is [Newtonsoft.Json.Linq.JArray]) {
        $a = @()
        foreach($entry in $obj.GetEnumerator()) {
            $a += @(convertfrom-jobject $entry)
        }
        return $a
   }
   elseif ($obj -is [Newtonsoft.Json.Linq.JObject]) {
       $h = [ordered]@{}
       foreach($kvp in $obj.GetEnumerator()) {
            $val =  convertfrom-jobject $kvp.value
            if ($kvp.value -is [Newtonsoft.Json.Linq.JArray]) { $val = @($val) }
            $h += @{ "$($kvp.key)" = $val }
       }
       return $h
   }
   elseif ($obj -is [Newtonsoft.Json.Linq.JValue]) {
        return $obj.Value
   }
   else {
    return $obj
   }
}