# Meta (Facebook) Audience Network SDK references Facebook's "infer" static
# analysis annotations, jo compile-time only hain aur APK me ship nahi hote.
# R8 inhe missing class samajh kar release build fail kar deta hai —
# in dono ko sirf warning-suppress karna safe hai (runtime par kabhi use
# nahi hote).
-dontwarn com.facebook.infer.annotation.Nullsafe$Mode
-dontwarn com.facebook.infer.annotation.Nullsafe
