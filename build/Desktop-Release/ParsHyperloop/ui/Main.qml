import QtQuick
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "Pars Hyperloop - 3D Görüntüleyici"

    View3D {
        id: view3D
        anchors.fill: parent

        // Arka plan rengi (koyu gri/uzay tonu)
        environment: SceneEnvironment {
            clearColor: "#1e1e24"
            backgroundMode: SceneEnvironment.Color
        }

        // Kamera
        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 100, 300)
            eulerRotation: Qt.vector3d(-15, 0, 0)
        }

        // Sahne Işıkları
        DirectionalLight {
            eulerRotation: Qt.vector3d(-45, 45, 0)
            brightness: 1.5
            castsShadow: true
        }

        DirectionalLight {
            eulerRotation: Qt.vector3d(45, -135, 0)
            brightness: 0.5
        }

        // Fare ile 3D model etrafında dönme / yakınlaşma kontrolleri
        OrbitCameraController {
            origin: sceneRoot
            camera: camera
        }

        // 3D Model Kök Düğümü
        Node {
            id: sceneRoot

            Model {
                id: hyperloopModel
                // GLB dosyasının yolu:
                source: "../assets/hyperloop3d.glb"

                // Model boyutu çok büyük veya küçük gelirse scale değerini ayarlayabilirsiniz:
                scale: Qt.vector3d(1.0, 1.0, 1.0)
                position: Qt.vector3d(0, 0, 0)
            }
        }
    }
}
