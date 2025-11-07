# 🔥 Firewall Whitelist Configuratie

## Overzicht

Het POS Setup script configureert de Windows Firewall om het systeem te beveiligen tegen externe dreigingen, terwijl essentiële diensten toegestaan blijven.

## Firewall Beleid

**Standaard beleid**: Blokkeer alle inkomend en uitgaand verkeer
**Uitzonderingen**: Alleen interne netwerken en whitelisted services

## ✅ Toegestane Netwerken (Interne LAN)

| Netwerkbereik | Beschrijving |
|---------------|--------------|
| `192.168.0.0/16` | Privé netwerk (Class C) |
| `10.0.0.0/8` | Privé netwerk (Class A) |
| `172.16.0.0/12` | Privé netwerk (Class B) |
| `127.0.0.1` | Localhost (loopback) |

## ✅ Whitelisted Services

### 1. Python POS Server Poorten
- **Poorten**: TCP 8001, 8002, 8003, 8004
- **Richting**: Inkomend & Uitgaand
- **Doel**: POS applicatie communicatie
- **Regel naam**: `POS Python Server Inbound/Outbound`

### 2. RustDesk Remote Management
- **Programma**: `C:\Program Files\RustDesk\rustdesk.exe`
- **Richting**: Inkomend & Uitgaand
- **Doel**: Externe toegang voor ondersteuning
- **Regel naam**: `RustDesk Service` / `RustDesk Service Out`
- **Versie**: Cislink pre-configured client

### 3. Chrome Remote Desktop
- **Programma**: `remoting_host.exe`
- **Locaties**:
  - `%LOCALAPPDATA%\Google\Chrome Remote Desktop\*\remoting_host.exe`
  - `C:\Program Files (x86)\Google\Chrome Remote Desktop\*\remoting_host.exe`
- **Richting**: Inkomend & Uitgaand
- **Doel**: Alternatieve externe toegang
- **Regel naam**: `Chrome Remote Desktop` / `Chrome Remote Desktop Out`

### 4. Cloudflare Services
- **Programma**: `cloudflared.exe`
- **Locaties**:
  - `C:\Program Files\cloudflared\cloudflared.exe`
  - `%LOCALAPPDATA%\cloudflared\cloudflared.exe`
  - `C:\cloudflared\cloudflared.exe`
- **Richting**: Inkomend & Uitgaand
- **Doel**: Cloudflare Tunnel connectiviteit
- **Regel naam**: `Cloudflare Tunnel` / `Cloudflare Tunnel Out`

### 5. HTTPS/HTTP Uitgaand
- **Poorten**: TCP 443 (HTTPS), TCP 80 (HTTP)
- **Richting**: Uitgaand
- **Doel**: Webtoegang voor updates en cloud services
- **Regel naam**: `HTTPS Outbound` / `HTTP Outbound`

### 6. DNS Uitgaand
- **Poorten**: UDP 53, TCP 53
- **Richting**: Uitgaand
- **Doel**: Naam resolutie
- **Regel naam**: `DNS Outbound` / `DNS TCP Outbound`

## 📋 Firewall Regels Beheer

### Alle POS regels bekijken
```powershell
Get-NetFirewallRule | Where-Object {
    $_.DisplayName -like "*POS*" -or
    $_.DisplayName -like "*RustDesk*" -or
    $_.DisplayName -like "*Chrome Remote*" -or
    $_.DisplayName -like "*Cloudflare*"
} | Format-Table DisplayName, Enabled, Direction, Action
```

### Specifieke regel controleren
```powershell
# Python server poorten
Get-NetFirewallRule -DisplayName "POS Python Server*"

# RustDesk
Get-NetFirewallRule -DisplayName "RustDesk*"

# Chrome Remote Desktop
Get-NetFirewallRule -DisplayName "Chrome Remote Desktop*"

# Cloudflare
Get-NetFirewallRule -DisplayName "Cloudflare*"
```

### Handmatig een regel toevoegen
```powershell
# Voorbeeld: Extra poort toevoegen
netsh advfirewall firewall add rule name="POS Extra Port" dir=in action=allow protocol=TCP localport=9000
```

### Regel verwijderen
```powershell
netsh advfirewall firewall delete rule name="POS Extra Port"
```

## 🔒 Beveiligingsnotities

1. **Minimale toegang**: Alleen noodzakelijke services zijn toegestaan
2. **Bidirectioneel**: Zowel inkomend als uitgaand verkeer wordt gecontroleerd
3. **Programma-specifiek**: Services zijn gebonden aan specifieke executables
4. **Herstelbaar**: Alle regels worden verwijderd door `POS_restore.ps1`

## ⚠️ Belangrijke Waarschuwingen

- **Wijzig het standaard beleid niet** zonder overleg
- **Test altijd** in een testomgeving voordat u wijzigingen doorvoert
- **Documenteer** alle handmatige firewall wijzigingen
- **Backup** configuratie voor disaster recovery

## 🛠️ Troubleshooting

### Service werkt niet door firewall
1. Controleer of de regel bestaat:
   ```powershell
   Get-NetFirewallRule -DisplayName "<Regel Naam>"
   ```

2. Controleer of de regel actief is:
   ```powershell
   Get-NetFirewallRule -DisplayName "<Regel Naam>" | Select-Object Enabled
   ```

3. Test connectiviteit:
   ```powershell
   Test-NetConnection -ComputerName <IP> -Port <Poort>
   ```

### Regel handmatig opnieuw aanmaken
```powershell
# Voorbeeld: Python server poorten
netsh advfirewall firewall delete rule name="POS Python Server Inbound"
netsh advfirewall firewall add rule name="POS Python Server Inbound" dir=in action=allow protocol=TCP localport=8001,8002,8003,8004
```

## 📞 Ondersteuning

Voor vragen over de firewall configuratie:
- Bekijk logs: `C:\POS\Logs\setup_*.log`
- Check documentatie: `README.md`, `QUICK_REFERENCE.md`
- Contact: IT ondersteuning

---

**Laatst bijgewerkt**: 2025-11-07
**Versie**: 3.1
**Auteur**: Cislink NL
