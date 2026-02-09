#ifndef HCT_BRIDGE_H
#define HCT_BRIDGE_H

extern "C" {
    // Hàm khởi tạo hệ thống từ tầng C++
    bool InitializeHCTCore();
    
    // Hàm xử lý dữ liệu siêu tốc cho StatusMonitor
    double ProcessSystemData(double input);
    
    // Hàm bảo mật: Kiểm tra xem code có bị sửa đổi không
    bool IntegrityCheck(const char* filePath);
}

#endif
