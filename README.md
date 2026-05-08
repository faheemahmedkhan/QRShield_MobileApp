# 🛡️ QRShield

**Your Personal QR Code Security Guard**

QRShield is a powerful mobile application that scans, analyzes, and protects you from malicious QR codes. Built with Flutter and powered by ML Kit, it provides real-time threat detection and detailed security analysis for every QR code you encounter.

## ✨ Features

### 🔍 **Intelligent QR Scanning**
- Real-time QR code detection using advanced ML Kit barcode scanning
- Support for multiple barcode formats
- High-speed, accurate decoding
- Smart threat classification (Safe, Suspicious, Dangerous)

### 📊 **Comprehensive Analysis**
- Deep URL analysis with SHAP explanations
- Detailed threat assessment and risk indicators
- Custom notes for each scan
- Real-time status reporting

### 📁 **Scan History**
- Persistent storage of all scan records with timestamps
- Full scan details including decoded URLs and threat status
- Searchable history for quick reference
- One-tap access to detailed scan information

### 📤 **Export & Share**
- Export scan history to PDF reports
- Export to Excel spreadsheets for bulk analysis
- Share reports with team members or security professionals
- Formatted reports with complete threat analysis

### 🌙 **Modern UI Experience**
- Beautiful dark and light themes
- Responsive design for all device sizes
- Smooth animations and intuitive navigation
- Tactical design with accent color schemes

### 📱 **Cross-Platform Support**
- iOS, Android, Web, Windows, macOS, and Linux
- Consistent experience across all platforms
- Device-optimized layouts

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.11.0 or higher
- Android 21+ / iOS 12+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd qrshield
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up native dependencies**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

QRShield leverages powerful open-source libraries:

- **flutter**: Core framework
- **google_mlkit_barcode_scanning**: ML-powered barcode detection
- **barcode_scanner**: Alternative barcode scanning
- **image_picker**: Photo library integration
- **pdf & excel**: Report generation
- **share_plus**: Cross-platform sharing
- **shared_preferences**: Local data persistence
- **url_launcher**: Safe URL handling
- **image**: Image processing and analysis

## 🎯 How to Use

1. **Open the Scanner**
   - Tap the Scanner tab to start scanning QR codes
   - Point your camera at a QR code
   - View instant threat analysis and decoded content

2. **Review History**
   - Access the History tab to see all scanned QR codes
   - View detailed information about each scan
   - Check threat status and analysis results

3. **Export Reports**
   - Long-press or select multiple scans
   - Export as PDF or Excel for documentation
   - Share with others for collaboration

4. **Customize Settings**
   - Toggle between dark and light themes
   - Adjust notification preferences
   - Manage scan history

## 🔒 Security & Privacy

- All scans are processed locally on your device
- Your scan history is stored securely using `shared_preferences`
- No data is sent to external servers without your consent
- Complete control over your data and history

## 🤝 Contributing

We welcome contributions! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📖 Learn More

- [Flutter Documentation](https://docs.flutter.dev/)
- [ML Kit Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning)
- [Flutter Best Practices](https://docs.flutter.dev/reference/best-practices)

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the incredible framework
- Google ML Kit for barcode scanning capabilities
- All contributors and users who help improve QRShield

---

**Stay Safe. Stay Protected. 🛡️**
