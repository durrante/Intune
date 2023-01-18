# What does it do?

Updates the in-built "Automatic-Device-Join" scheduled task @ Logon of any user from a default delay of 1-minute to 2 minutes. This may be required when pre-login VPNs drop \ reconnect at a critical point of the Autopilot Hybrid AD join process.

# Before

![image](https://user-images.githubusercontent.com/64601521/213146317-0dfe277f-debe-423b-8512-855fd49c7496.png)

# After

![image](https://user-images.githubusercontent.com/64601521/213146402-18f95921-40a3-4ad5-9750-5ae288c514f9.png)

# How to edit the delay criteria?

The delay uses the 8601 ISO standard, see more here: https://tc39.es/proposal-temporal/docs/duration.html
