import boto3
from flask import Flask, render_template, request, session, redirect, url_for

app = Flask(__name__)
app.secret_key = "CHANGE_THIS_SECRET_KEY"

# ---------------------------------------------------------
# AWS REGIONS
# ---------------------------------------------------------
AWS_REGIONS = {
    "North America": {
        "us-east-1": "N. Virginia",
        "us-east-2": "Ohio",
        "us-west-1": "N. California",
        "us-west-2": "Oregon",
        "ca-central-1": "Montreal"
    },
    "South America": {
        "sa-east-1": "São Paulo"
    },
    "Europe": {
        "eu-west-1": "Ireland",
        "eu-west-2": "London",
        "eu-west-3": "Paris",
        "eu-north-1": "Stockholm",
        "eu-south-1": "Milan",
        "eu-central-1": "Frankfurt"
    },
    "Asia Pacific": {
        "ap-south-1": "Mumbai",
        "ap-south-2": "Hyderabad",
        "ap-southeast-1": "Singapore",
        "ap-southeast-2": "Sydney",
        "ap-southeast-3": "Jakarta",
        "ap-northeast-1": "Tokyo",
        "ap-northeast-2": "Seoul",
        "ap-northeast-3": "Osaka"
    },
    "Middle East": {
        "me-south-1": "Bahrain",
        "me-central-1": "UAE"
    },
    "Africa": {
        "af-south-1": "Cape Town"
    }
}

# ---------------------------------------------------------
# AWS CLIENT INITIALIZATION
# ---------------------------------------------------------
def get_clients():
    if "access_key" not in session:
        return None, None
    try:
        sess = boto3.Session(
            aws_access_key_id=session["access_key"],
            aws_secret_access_key=session["secret_key"],
            region_name=session["region"]
        )
        return sess.client("ec2"), sess.client("elbv2")
    except:
        return None, None


# ---------------------------------------------------------
# LOGIN PAGE
# ---------------------------------------------------------
@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        access_key = request.form["access_key"]
        secret_key = request.form["secret_key"]
        region = request.form["region"]

        # Test AWS credentials
        try:
            sts = boto3.client(
                "sts",
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key,
                region_name=region
            )
            sts.get_caller_identity()
        except:
            return "Invalid AWS credentials"

        session["access_key"] = access_key
        session["secret_key"] = secret_key
        session["region"] = region

        return redirect("/")

    return render_template("login.html", region_groups=AWS_REGIONS)


# ---------------------------------------------------------
# LOGOUT
# ---------------------------------------------------------
@app.route("/logout")
def logout():
    session.clear()
    return redirect("/login")


# ---------------------------------------------------------
# DASHBOARD PAGE
# ---------------------------------------------------------
@app.route("/")
def home():
    
    # ✅ Redirect user if NOT logged in
    if "access_key" not in session:
        return redirect("/login")
        
    ec2, elb = get_clients()
    instance_data, vpc_data, subnet_data, lb_data, ami_data = [], [], [], [], []

    if ec2:

        # EC2 Instances
        try:
            for r in ec2.describe_instances()["Reservations"]:
                for inst in r["Instances"]:
                    name = next((t["Value"] for t in inst.get("Tags", []) if t["Key"] == "Name"), "N/A")
                    instance_data.append({
                        "Name": name,
                        "ID": inst["InstanceId"],
                        "State": inst["State"]["Name"],
                        "Type": inst["InstanceType"],
                        "Public IP": inst.get("PublicIpAddress", "N/A")
                    })
        except:
            pass

        # VPCs
        try:
            vpc_data = [{"VPC ID": v["VpcId"], "CIDR": v["CidrBlock"]} for v in ec2.describe_vpcs()["Vpcs"]]
        except:
            pass

        # Subnets
        try:
            subnet_data = [{
                "Subnet ID": s["SubnetId"],
                "VPC ID": s["VpcId"],
                "CIDR": s["CidrBlock"],
                "Availability Zone": s["AvailabilityZone"]
            } for s in ec2.describe_subnets()["Subnets"]]
        except:
            pass

        # AMIs
        try:
            ami_data = [{
                "AMI ID": a["ImageId"],
                "Name": a.get("Name", "N/A")
            } for a in ec2.describe_images(Owners=["self"])["Images"]]
        except:
            pass

    if elb:
        # Load Balancers
        try:
            lb_data = [{
                "LB Name": lb["LoadBalancerName"],
                "DNS Name": lb["DNSName"]
            } for lb in elb.describe_load_balancers()["LoadBalancers"]]
        except:
            pass

    return render_template(
        "dashboard.html",
        instance_data=instance_data,
        vpc_data=vpc_data,
        subnet_data=subnet_data,
        lb_data=lb_data,
        ami_data=ami_data
    )


# ---------------------------------------------------------
# RUN APP
# ---------------------------------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
