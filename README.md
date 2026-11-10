
## Sayfa Odaklı Klasör Yapısı
Arayüz dosyaları `Main.qml` penceresinden içeriye doğru **sayfa odaklı (page-first)** olarak gruplandırılmıştır:

```text
ground-station/ParsHyperloop/
├── CMakeLists.txt
├── src/
│   └── main.cpp                                  
├── assets/
│   ├── hyperloop3d.glb                   
│   ├── teampars.png
│   ├── ikculogo.png                              
│   └── fonts/                                    
└── ui/
    ├── Main.qml           
    ├── Colors.qml                                
    │
    ├── shell/                             
    │   ├── TopControlBar.qml                   
    │   ├── NotificationLogPanel.qml              
    │   └── BottomNavigationBar.qml
    │
    └── views/                                
        │
        ├── overview/                        
        │   ├── OverviewPage.qml                 
        │   ├── OverviewModeSwitch.qml         
        │   ├── OverviewDetailSection.qml      
        │   │
        │   ├── pod3d/                         
        │   │   └── Pod3DInspectionScene.qml       
        │   │
        │   └── cockpit/                           
        │       ├── CompetitionCockpit.qml         
        │       ├── CockpitPhysicsEngine.qml     
        │       ├── CockpitSweepAnimator.qml       
        │       ├── CockpitBorderFrame.qml        
        │       ├── TunnelProgressMap.qml        
        │       ├── LeftSpeedPanel.qml            
        │       ├── CenterCommandPanel.qml         
        │       ├── RightPowerPanel.qml            
        │       ├── Tunnel3DRingsCanvas.qml       
        │       ├── BatteryCellsCanvas.qml   
        │       └── OscilloscopeGraph.qml  
        │
        ├── safety/            
        │   └── SafetyPage.qml                
        │
        ├── battery/
        │   └── BatteryPage.qml           
        │
        ├── brake/
        │   └── BrakePage.qml 
        │
        └── communication/          
            └── CommunicationPage.qml  
```
