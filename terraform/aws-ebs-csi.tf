# EBS CSI driver – IAM role (IRSA) + EKS add-on


# 1) Trust policy so the driver’s ServiceAccount can assume this role
data "aws_iam_policy_document" "ebs_csi_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]          # from v19 module
    }

    condition {
      test     = "StringEquals"
      # strip the https:// prefix from issuer URL
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name               = "ebs-csi-${module.eks.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# 2) Ask EKS to install the official AWS EBS CSI add-on and
#    bind it to the IAM role above
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  # let AWS pick the latest compatible version, or pin if you prefer:
  # addon_version = "v1.30.0-eksbuild.1"

  # ensure the cluster & node groups exist first
  depends_on = [module.eks]
}
