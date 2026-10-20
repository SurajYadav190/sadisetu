package com.shadisetu.repository;

import com.shadisetu.entity.ServicePackage;
import com.shadisetu.entity.VendorProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ServicePackageRepository extends JpaRepository<ServicePackage, Long> {
    List<ServicePackage> findByVendorAndActiveTrue(VendorProfile vendor);
    List<ServicePackage> findByVendorIdAndActiveTrue(Long vendorId);
}
