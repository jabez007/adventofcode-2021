%dw 2.0

output application/json
---
dw::util::Timer::duration(() -> do {
    var scanners = (
        (payload splitBy /--- scanner (\d+) ---/) filter (not isEmpty($))
     ) map (trim($) splitBy "\n")
    ---
    scanners
})
