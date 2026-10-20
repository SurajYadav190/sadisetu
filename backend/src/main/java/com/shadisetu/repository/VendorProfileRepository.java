package com.shadisetu.repository;

import com.shadisetu.entity.VendorProfile;
import com.shadisetu.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VendorProfileRepository extends JpaRepository<VendorProfile, Long> {
    Optional<VendorProfile> findByUser(User user);
    Optional<VendorProfile> findByUserId(Long userId);
    List<VendorProfile> findByKycStatus(String kycStatus);
    List<VendorProfile> findByCategoryIdAndKycStatus(Long categoryId, String kycStatus);

    @Query("SELECT v FROM VendorProfile v WHERE v.kycStatus = 'VERIFIED' " +
           "AND (:categoryId IS NULL OR v.category.id = :categoryId) " +
           "AND (:city IS NULL OR LOWER(v.city) LIKE LOWER(CONCAT('%', :city, '%'))) " +
           "AND (:query IS NULL OR LOWER(v.businessName) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<VendorProfile> searchVerifiedVendors(@Param("categoryId") Long categoryId,
                                              @Param("city") String city,
                                              @Param("query") String query);

    long countByKycStatus(String kycStatus);
}
