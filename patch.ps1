# Backup original files
Copy-Item -Path "LIBRARY\makefile.mak" -Destination "LIBRARY\makefile.mak.bak"
Copy-Item -Path "LIBRARY\src\bid_conf.h" -Destination "LIBRARY\src\bid_conf.h.bak"
Copy-Item -Path "LIBRARY\src\bid_functions.h" -Destination "LIBRARY\src\bid_functions.h.bak"

# Modify makefile.mak
$makefile = "LIBRARY\makefile.mak"
$lines = Get-Content $makefile

# Replace line 36: AR=lib with AR=link
$lines[35] = "AR=link"

# Replace line 102: BID_LIB=libbid.lib with BID_LIB=biddll.dll
$lines[101] = "BID_LIB=biddll.dll"

# Replace line 228: Add /DLL
$lines[227] = $lines[227] -replace '/OUT:', '/DLL /OUT:'

# Replace line 233: Add /DLL
$lines[232] = $lines[232] -replace '/OUT:', '/DLL /OUT:'

# Write changes to makefile.mak
Set-Content -Path $makefile -Value $lines

# Modify bid_conf.h
$bidConf = "LIBRARY\src\bid_conf.h"
$confLines = Get-Content $bidConf
$insertBlock = @"
#ifndef BID_EXTERN_C_EXT
#ifdef __cplusplus
#define BID_EXTERN_C_EXT extern "C" __declspec(dllexport)
#else
#define BID_EXTERN_C_EXT extern __declspec(dllexport)
#endif
#endif
"@
# Insert block at line 36
$confLines = $confLines[0..34] + $insertBlock.Split("`n") + $confLines[35..($confLines.Length -1)]
Set-Content -Path $bidConf -Value $confLines

# Modify bid_functions.h
$bidFunctions = "LIBRARY\src\bid_functions.h"
$funcLines = Get-Content $bidFunctions

$replacements = @{
    3384 = '     BID_EXTERN_C_EXT BID_UINT64 bid64_add (BID_UINT64 x, BID_UINT64 y'
    3396 = '     BID_EXTERN_C_EXT BID_UINT64 bid64_sub (BID_UINT64 x,'
    3409 = '     BID_EXTERN_C_EXT BID_UINT64 bid64_mul (BID_UINT64 x, BID_UINT64 y'
    3421 = '     BID_EXTERN_C_EXT BID_UINT64 bid64_div (BID_UINT64 x,'
    4819 = '     BID_EXTERN_C_EXT void bid64_to_string (char *ps, BID_UINT64 x'
    4822 = '     BID_EXTERN_C_EXT BID_UINT64 bid64_from_string (char *ps'
    4870 = '     BID_EXTERN_C_EXT BID_UINT64 binary64_to_bid64 (double x'
    4938 = '     BID_EXTERN_C_EXT double bid64_to_binary64 (BID_UINT64 x'
}

foreach ($lineNum in $replacements.Keys) {
    if ($lineNum -lt $funcLines.Length) {
        $funcLines[$lineNum] = $replacements[$lineNum]
    }
}

Set-Content -Path $bidFunctions -Value $funcLines